# Mimir — metrics (Prometheus-compatible). Monolithic single-process mode,
# loopback only; Grafana scrapes/queries it locally.
{ ... }:
let
  ports = import ./ports.nix;
  retention = "4320h"; # 180 days
in
{
  services.mimir = {
    enable = true;
    configuration = {
      target = "all"; # monolithic single-process mode
      multitenancy_enabled = false;
      server = {
        http_listen_address = "127.0.0.1";
        http_listen_port = ports.mimir;
        grpc_listen_port = ports.mimirGrpc;
      };
      common.storage = {
        backend = "filesystem";
        filesystem.dir = "/var/lib/mimir/data";
      };
      blocks_storage = {
        backend = "filesystem";
        tsdb.dir = "/var/lib/mimir/tsdb";
        bucket_store.sync_dir = "/var/lib/mimir/tsdb-sync";
      };
      compactor = {
        data_dir = "/var/lib/mimir/compactor";
        sharding_ring.kvstore.store = "inmemory";
      };
      store_gateway.sharding_ring.kvstore.store = "inmemory";
      # Single-instance: write quorum must be 1. Mimir defaults to
      # replication_factor 3, whose quorum (2 live ingesters) a one-node
      # install can never satisfy — pushes 500 with
      # "at least 2 live replicas required, could only find 1".
      ingester.ring = {
        kvstore.store = "inmemory";
        replication_factor = 1;
      };
      # Retention: delete blocks older than `retention`. Mimir's default is
      # 0s (keep forever), which is what we had before — unsafe on a Pi.
      limits.compactor_blocks_retention_period = retention;
      ruler_storage = {
        backend = "filesystem";
        filesystem.dir = "/var/lib/mimir/rules";
      };
      alertmanager_storage = {
        backend = "filesystem";
        filesystem.dir = "/var/lib/mimir/alertmanager";
      };
    };
  };
}
