{ config, ... }:

let
  pushIpaddress = if config.hostLogs then "127.0.0.1" else config.logHosterIpaddress;
in
{
  services.promtail = {
    enable = true;
    configuration = {
      server = {
        http_listen_port = config.promtailListenPort;
        grpc_listen_port = 0;
      };
      positions = {
        filename = "/tmp/positions.yaml";
      };
      clients = [
        {
          url = "http://${pushIpaddress}:${toString config.lokiListenPort}/loki/api/v1/push";
        }
      ];
      scrape_configs = [
        {
          job_name = "journal";
          journal = {
            max_age = "12h";
            labels = {
              job = "systemd-journal";
              host = config.networking.hostname;
            };
          };
          relabel_configs = [
            {
              source_labels = [ "__journal__systemd_unit" ];
              target_label = "unit";
            }
          ];
        }
      ];
    };
  };
}
