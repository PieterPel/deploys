{ lib, ... }:
{

  options = {
    perhapsPort = lib.mkOption {
      type = lib.types.int;
      default = 3000;
      description = "Port of perhaps app";
    };
  };
}
