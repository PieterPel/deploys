{ lib, config, ... }:

let
  nginxProxy = import ../../helpers/nginx-proxy.nix;
  ipaddress = config.hosts.${config.networking.hostName}.ip;
in
lib.mkIf config.hostLogs (
  lib.mkMerge [
    (nginxProxy {
      inherit lib config;
      name = "grafana";
      port = config.grafanaPort;
      ip = ipaddress;
      websockets = true;
    })
    (nginxProxy {
      inherit lib config;
      name = "prometheus";
      port = config.prometheusPort;
      ip = ipaddress;
    })
    (nginxProxy {
      inherit lib config;
      name = "loki";
      port = config.lokiListenPort;
      ip = ipaddress;
    })
    (nginxProxy {
      inherit lib config;
      name = "promtail";
      port = config.promtailListenPort;
      ip = ipaddress;
    })
  ]
)
