{ lib
, config
, name
, port
, ip
, websockets ? false
,
}:

{
  services.nginx = {
    upstreams.${name} = {
      servers = {
        "127.0.0.1:${toString port}" = { };
      };
    };

    virtualHosts.${name} = {
      serverName = "${name}.local";
      locations."/" = {
        proxyPass = "http://${name}";
        proxyWebsockets = websockets;
      };
      listen = [
        {
          addr = ip;
          port = port;
        }
      ];
    };
  };

  networking.firewall.allowedTCPPorts = [ port ];
}
