# The LGTM observability stack: Loki, Grafana, Tempo, Mimir.
# All four run as native NixOS systemd services (no containers).
#
# - Grafana is reachable on the LAN (0.0.0.0:3000, opened in the firewall).
# - The backends (Loki/Tempo/Mimir) listen on the loopback interface only;
#   Grafana talks to them locally. Open their ports if you need remote
#   ingestion from other hosts.
{
  imports = [
    ./grafana.nix
    ./loki.nix
    ./tempo.nix
    ./mimir.nix
    ./collector.nix
    ./node-exporter.nix
  ];
}
