{ config, ... }:
let
  clientPort = 3021;
in
{
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
            targets = [
              # This scrapes the logs of the host itself
              "127.0.0.1:${clientPort}"

              # TODO: find nice way to set up scraping of other machines
            ];
          }
        ];
      }
    ];
  };
}
