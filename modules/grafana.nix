{ config, ... }:
{
  services.grafana = {
    port = config.grafanaPort;
    # WARNING: this should match nginx setup!
    # prevents "Request origin is not authorized"
    rootUrl = "http://${config.ipaddress}:8010"; # helps with nginx / ws / live

    protocol = "http";
    addr = "127.0.0.1";
    analytics.reporting.enable = false;
    enable = config.hostLogs;

    provision = {
      enable = true;
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
}
