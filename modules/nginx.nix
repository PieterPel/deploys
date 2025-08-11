{ config, ... }:
{
  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    recommendedOptimisation = true;
    recommendedGzipSettings = true;

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
      locations."/" = {
        proxyPass = "http://grafana";
        proxyWebsockets = true;
      };
      listen = [
        {
          addr = config.logHosterIpaddress;
          port = 8010;
        }
      ];
    };

    virtualHosts.prometheus = {
      locations."/".proxyPass = "http://prometheus";
      listen = [
        {
          addr = config.logHosterIpaddress;
          port = 8020;
        }
      ];
    };

    # confirm with http://192.168.1.10:8030/loki/api/v1/status/buildinfo
    #     (or)     /config /metrics /ready
    virtualHosts.loki = {
      locations."/".proxyPass = "http://loki";
      listen = [
        {
          addr = config.logHosterIpaddress;
          port = 8030;
        }
      ];
    };

    virtualHosts.promtail = {
      locations."/".proxyPass = "http://promtail";
      listen = [
        {
          addr = config.logHosterIpaddress;
          port = 8031;
        }
      ];
    };
  };
}
