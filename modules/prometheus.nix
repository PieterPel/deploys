{ config, ... }:
let
  clientPort = 3021;

  remoteTargets = builtins.attrValues (
    builtins.mapAttrs (_: host: "${host.ip}:${toString clientPort}") config.hosts
  );

  targets = [ "127.0.0.1:${toString clientPort}" ] ++ remoteTargets;
in
{
  networking.firewall.allowedTCPPorts = [ clientPort ];
  services.prometheus = {
    port = config.prometheusPort;
    enable = config.hostLogs;

    exporters = {
      node = {
        port = clientPort;
        enabledCollectors = [ "systemd" ];
        enable = true;
      };
    };

    # ingest the published nodes
    scrapeConfigs = [
      {
        job_name = "nodes";
        static_configs = [
          {
            inherit targets;
          }
        ];
      }
    ];
  };
}
