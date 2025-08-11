{ config, lib, ... }:

{
  options = {
    hosts = lib.mkOption {
      type = lib.types.attrsOf (
        lib.types.submodule (_: {
          options.ip = lib.mkOption {
            type = lib.types.str;
            description = "IP address of the host";
          };
        })
      );
      default = { };
      description = "A map of all hosts in the deployment.";
    };

    logsHoster = lib.mkOption {
      type = lib.types.str;
      description = "The host that hosts the logs";
    };
    perhapsHoster = lib.mkOption {
      type = lib.types.str;
      description = "The host that hosts the perhaps app";
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

    # Derived options
    hostPerhaps = lib.mkOption {
      type = lib.types.bool;
      readOnly = true;
      default = config.networking.hostName == config.perhapsHoster;
      description = "Whether this host is the perhaps hoster";
    };

    hostLogs = lib.mkOption {
      type = lib.types.bool;
      readOnly = true;
      default = config.networking.hostName == config.logsHoster;
      description = "Whether this host is the logs hoster";
    };
  };

  config = {
    assertions = [
      {
        assertion = builtins.hasAttr config.logsHoster config.hosts;
        message = "logsHoster '${config.logsHoster}' is not defined in hosts";
      }
      {
        assertion = builtins.hasAttr config.perhapsHoster config.hosts;
        message = "perhapsHoster '${config.perhapsHoster}' is not defined in hosts";
      }
    ];
  };
}
