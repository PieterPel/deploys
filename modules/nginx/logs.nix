{ lib, config, ... }:

lib.mkIf config.hostLogs {
  services.nginx = {
    upstreams = {
      "grafana" = {
        servers = {
          "127.0.0.1:${toString config.grafanaPort}" = { };
        };
      };
      "prometheus" = {
        servers = {
          "127.0.0.1:${toString config.prometheusPort}" = { };
        };
      };
      "loki" = {
        servers = {
          "127.0.0.1:${toString config.lokiListenPort}" = { };
        };
      };
      "promtail" = {
        servers = {
          "127.0.0.1:${toString config.promptailListenPort}" = { };
        };
      };
    };

    virtualHosts.grafana = {
      serverName = "grafana.local";
      locations."/" = {
        proxyPass = "http://grafana";
        proxyWebsockets = true;
      };
      listen = [
        {
          addr = config.logHosterIpaddress;
          port = config.grafanaPort;
        }
      ];
    };

    virtualHosts.prometheus = {
      serverName = "prometheus.local";
      locations."/".proxyPass = "http://prometheus";
      listen = [
        {
          addr = config.logHosterIpaddress;
          port = config.prometheusPort;
        }
      ];
    };

    virtualHosts.loki = {
      serverName = "loki.local";
      locations."/".proxyPass = "http://loki";
      listen = [
        {
          addr = config.logHosterIpaddress;
          port = config.lokiListenPort;
        }
      ];
    };

    virtualHosts.promtail = {
      serverName = "promtail.local";
      locations."/".proxyPass = "http://promtail";
      listen = [
        {
          addr = config.logHosterIpaddress;
          port = config.promptailListenPort;
        }
      ];
    };
  };
}
