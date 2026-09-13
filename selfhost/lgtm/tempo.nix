# Tempo — distributed tracing. Receives OTLP over loopback only; Grafana
# queries it locally. Open the OTLP ports for remote ingestors.
{ ... }:
let
  ports = import ./ports.nix;
in
{
  services.tempo = {
    enable = true;
    settings = {
      server = {
        http_listen_address = "127.0.0.1";
        http_listen_port = ports.tempo;
        grpc_listen_address = "127.0.0.1";
        grpc_listen_port = ports.tempoGrpc;
      };
      distributor.receivers.otlp.protocols = {
        grpc.endpoint = "127.0.0.1:${toString ports.tempoOtlpGrpc}";
        http.endpoint = "127.0.0.1:${toString ports.tempoOtlpHttp}";
      };
      storage.trace = {
        backend = "local";
        local.path = "/var/lib/tempo/blocks";
        wal.path = "/var/lib/tempo/wal";
      };
      ingester = {
        trace_idle_period = "30s";
        max_block_bytes = 1048576; # 1 MiB, small for the Pi
        max_block_duration = "5m";
      };
    };
  };
}
