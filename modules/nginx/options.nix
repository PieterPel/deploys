{ lib, ... }:
{

  options = {
    hostPerhaps = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to host the perhaps app";
    };
    perhapsPort = lib.mkOption {
      type = lib.types.int;
      default = 3000;
      description = "Port of perhaps app";
    };
    perhapsHosterIpaddress = lib.mkOption {
      type = lib.types.str;
      description = "IP address of perhaps hoster";
    };
  };
}
