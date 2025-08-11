{ config, ... }:

let
  ipaddress = config.hosts.${config.networking.hostName}.ip;
in
{
  services.grafana = {
    enable = config.hostLogs;

    # grafana.ini settings
    settings = {
      analytics.reporting_enabled = false;

      server = {
        http_port = config.grafanaPort;
        http_addr = "127.0.0.1";
        protocol = "http";
        # WARNING: this should match nginx setup!
        # prevents "Request origin is not authorized"
        root_url = "http://${ipaddress}:${toString config.grafanaPort}";
      };
    };

    # provisioning YAML
    provision = {
      enable = true;
      datasources.settings = {
        apiVersion = 1;
        datasources = [
          {
            name = "Prometheus";
            type = "prometheus";
            access = "proxy";
            url = "http://127.0.0.1:${toString config.prometheusPort}";
          }
          {
            name = "Loki";
            type = "loki";
            access = "proxy";
            url = "http://127.0.0.1:${toString config.lokiListenPort}";
          }
        ];
      };
    };
  };
}
