{ lib, config, ... }:

let
  nginxProxy = import ../../helpers/nginx-proxy.nix;
in
lib.mkIf config.hostPerhaps (nginxProxy {
  inherit lib config;
  name = "perhaps";
  port = config.perhapsPort;
  ip = config.hosts.${config.perhapsHoster}.ip;
})
