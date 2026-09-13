# Loki — log aggregation. Single-tenant, loopback only; Grafana queries it
# locally. Open the port if you want remote ingestion.
{ ... }:
let
  ports = import ./ports.nix;
in
{
  services.loki = {
    enable = true;
    configuration = {
      auth_enabled = false; # single-tenant
      server = {
        http_listen_address = "127.0.0.1";
        http_listen_port = ports.loki;
        # gRPC is intentionally not pinned to loopback. Loki's monolith
        # has components (distributor/ingester, frontend/scheduler/querier)
        # that self-dial gRPC using the address auto-detected on the LAN
        # iface; loopback-only breaks every push/query with "connection
        # refused". The firewall keeps this port off the LAN. See mimir.nix.
        grpc_listen_port = ports.lokiGrpc;
      };
      common = {
        path_prefix = "/var/lib/loki";
        replication_factor = 1;
        ring = {
          kvstore.store = "inmemory";
          # Advertise loopback so ring members reach each other locally.
          instance_addr = "127.0.0.1";
        };
        storage.filesystem = {
          chunks_directory = "/var/lib/loki/chunks";
          rules_directory = "/var/lib/loki/rules";
        };
      };
      schema_config.configs = [
        {
          from = "2024-01-01";
          store = "tsdb";
          object_store = "filesystem";
          schema = "v13";
          index = {
            prefix = "index_";
            period = "24h";
          };
        }
      ];
      limits_config.allow_structured_metadata = true;
    };
  };
}
