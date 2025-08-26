{ config, ... }:
{
  services.loki = {
    enable = config.hostLogs;
    configuration = {
      server = {
        http_listen_port = config.lokiListenPort;
      };
      auth_enabled = false;

      ingester = {
        lifecycler = {
          address = "127.0.0.1";
          ring = {
            kvstore = {
              store = "inmemory";
            };
            replication_factor = 1;
          };
        };
        chunk_idle_period = "1h";
        max_chunk_age = "1h";
        chunk_target_size = 999999;
        chunk_retain_period = "30s";
      };

      schema_config = {
        configs = [
          {
            from = "2025-08-08";
            store = "tsdb";
            object_store = "filesystem";
            schema = "v13";
            index = {
              prefix = "index_";
              period = "24h";
            };
          }
        ];
      };

      storage_config = {
        tsdb_shipper = {
          active_index_directory = "/var/lib/loki/tsdb-shipper-active";
          cache_location = "/var/lib/loki/tsdb-shipper-cache";
          cache_ttl = "24h";
        };
        filesystem = {
          directory = "/var/lib/loki/chunks";
        };
      };
      #
      # limits_config = {
      #   reject_old_samples = true;
      #   reject_old_samples_max_age = "168h";
      #   retention_period = "168h"; # 7 days retention
      # };
      #
      # compactor = {
      #   working_directory = "/var/lib/loki";
      #   compaction_interval = "10m";
      #   retention_enabled = true;
      #   retention_delete_delay = "2h";
      #   retention_delete_worker_count = 150;
      #
      #   delete_request_store = {
      #     store = "boltdb";
      #     boltdb = {
      #       directory = "/var/lib/loki/compactor-delete-requests";
      #     };
      #   };
      #
      #   compactor_ring = {
      #     kvstore = {
      #       store = "inmemory";
      #     };
      #   };
      # };
    };
  };
}
