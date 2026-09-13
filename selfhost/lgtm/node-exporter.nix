# node_exporter — host metrics (CPU, memory, disks, network, filesystem, ...)
# in Prometheus exposition format. Scraped by the OpenTelemetry collector over
# loopback (see collector.nix) and forwarded to Mimir, so it is intentionally
# NOT exposed on the LAN. The default collector set matches what the standard
# node-exporter Grafana dashboards expect.
#
# Tip: add `enabledCollectors = [ "systemd" ]` to also export systemd unit
# state — useful on NixOS, but it pulls D-Bus + polkit into the closure.
{ ... }:
let
  ports = import ./ports.nix;
in
{
  services.prometheus.exporters.node = {
    enable = true;
    listenAddress = "127.0.0.1";
    port = ports.nodeExporter;
  };
}
