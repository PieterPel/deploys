{ lib, config, ... }:

lib.mkIf config.hostPerhaps {
  services.nginx = {
    upstreams = {
      "perhaps" = {
        servers = {
          "127.0.0.1:${toString config.perhapsPort}" = { };
        };
      };
    };

    virtualHosts.perhaps = {
      serverName = "perhaps.local";
      locations."/" = {
        proxyPass = "http://perhaps";
      };
      listen = [
        {
          addr = config.perhapsHosterIpaddress;
          port = config.perhapsPort;
        }
      ];
    };
  };

  networking.firewall.allowedTCPPorts = [ config.perhapsPort ];
}
