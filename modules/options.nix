{ lib, ... }:
{

  options = {
    ipaddress = lib.mkOption {
      type = lib.types.str;
      description = "IP address of host";
    };

    hostLogs = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Host apps to pull logs from other machines";
    };

    logHosterIpaddress = lib.mkOption {
      type = lib.types.str;
      description = "IP address of log hoster";
    };

    lokiListenPort = lib.mkOption {
      type = lib.types.int;
      default = 3030;
      description = "Loki listen port";
    };

    promtailListenPort = lib.mkOption {
      type = lib.types.int;
      default = 3031;
      description = "Promtail listen port";
    };

    prometheusPort = lib.mkOption {
      type = lib.types.int;
      default = 3020;
      description = "Prometheus listen port";
    };

    grafanaPort = lib.mkOption {
      type = lib.types.int;
      default = 3010;
      description = "Grafana listen port";
    };
  };
}
