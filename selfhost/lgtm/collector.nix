# OpenTelemetry Collector — the single OTLP ingress point on the LAN
# (4317 gRPC / 4318 HTTP). One endpoint receives every signal from
# OTel-compatible SDKs; the collector then fans them out:
#
#   traces  -> Tempo   (loopback OTLP)
#   metrics -> Mimir   (loopback Prometheus remote_write)
#   logs    -> Loki    (loopback OTLP, Loki >= 3.0 native OTLP ingestion)
#
# It additionally scrapes the local node_exporter (prometheus receiver) so
# host metrics reach Mimir through the same metrics pipeline.
{ pkgs, ... }:
let
  ports = import ./ports.nix;
in
{
  networking.firewall.allowedTCPPorts = [
    ports.otlpGrpc
    ports.otlpHttp
  ];

  services.opentelemetry-collector = {
    enable = true;
    package = pkgs.opentelemetry-collector-contrib;
    settings = {
      receivers = {
        otlp.protocols = {
          grpc.endpoint = "0.0.0.0:${toString ports.otlpGrpc}";
          http.endpoint = "0.0.0.0:${toString ports.otlpHttp}";
        };
        # Scrape the local node_exporter and feed the metrics into the same
        # pipeline as OTLP metrics below (-> Mimir via remote_write). The
        # `prometheus` receiver ships in the -contrib package we use.
        prometheus.config.scrape_configs = [
          {
            job_name = "node";
            scrape_interval = "15s";
            static_configs = [
              { targets = [ "127.0.0.1:${toString ports.nodeExporter}" ]; }
            ];
          }
        ];
      };

      processors = {
        memory_limiter = {
          check_interval = "1s";
          limit_percentage = 80;
          spike_limit_percentage = 25;
        };
        batch = { };
      };

      exporters = {
        # traces -> Tempo
        otlp = {
          endpoint = "127.0.0.1:${toString ports.tempoOtlpGrpc}";
          tls.insecure = true;
        };
        # metrics -> Mimir (Prometheus-compatible remote_write)
        prometheusremotewrite = {
          endpoint = "http://127.0.0.1:${toString ports.mimir}/api/v1/push";
        };
        # logs -> Loki via its native OTLP/HTTP endpoint (Loki >= 3.0).
        # The contrib `loki` exporter is deprecated and slated for removal;
        # native OTLP keeps resource/log attributes as structured metadata
        # (Loki needs `allow_structured_metadata = true`, set in loki.nix).
        "otlphttp/loki" = {
          endpoint = "http://127.0.0.1:${toString ports.loki}/otlp";
        };
      };

      service.pipelines = {
        traces = {
          receivers = [ "otlp" ];
          processors = [ "memory_limiter" "batch" ];
          exporters = [ "otlp" ];
        };
        metrics = {
          receivers = [ "otlp" "prometheus" ];
          processors = [ "memory_limiter" "batch" ];
          exporters = [ "prometheusremotewrite" ];
        };
        logs = {
          receivers = [ "otlp" ];
          processors = [ "memory_limiter" "batch" ];
          exporters = [ "otlphttp/loki" ];
        };
      };
    };
  };
}
