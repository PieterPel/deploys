{ lib, config, ... }:

let
  nginxProxy = import ../../helpers/nginx-proxy.nix;
in
lib.mkIf config.hostLogs (
  lib.mkMerge [
    (nginxProxy {
      inherit lib config;
      name = "grafana";
      port = config.grafanaPort;
      ip = config.logHosterIpaddress;
      websockets = true;
    })
    (nginxProxy {
      inherit lib config;
      name = "prometheus";
      port = config.prometheusPort;
      ip = config.logHosterIpaddress;
    })
    (nginxProxy {
      inherit lib config;
      name = "loki";
      port = config.lokiListenPort;
      ip = config.logHosterIpaddress;
    })
    (nginxProxy {
      inherit lib config;
      name = "promtail";
      port = config.promptailListenPort;
      ip = config.logHosterIpaddress;
    })
  ]
)
