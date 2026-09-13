# TCP port assignments for the LGTM stack. Shared so Grafana's datasource
# URLs stay in sync with the actual listen ports of the backends.
{
  grafana = 3000;
  # loki
  loki = 3100;
  lokiGrpc = 9097;
  # tempo
  tempo = 3200;
  tempoGrpc = 9096;
  # the standard otlp ports (4317/4318) are owned by the opentelemetry collector,
  # which fans out traces -> tempo and metrics -> mimir.
  tempoOtlpGrpc = 14317;
  tempoOtlpHttp = 14318;
  # mimir
  mimir = 9009;
  mimirGrpc = 9095;
  # otel endpoint
  otlpGrpc = 4317; # OTel Collector, exposed on the LAN
  otlpHttp = 4318;
  # node_exporter, scraped by the OTel collector over loopback
  nodeExporter = 9100;
}
