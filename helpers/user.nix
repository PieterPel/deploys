{ lib, pkgs }:

let
  mkAppUser = { name, home ? "/home/${name}", shell ? pkgs.bash, extraConfig ? { } }: {
    users.users.${name} = lib.mkMerge [
      {
        isNormalUser = true;
        inherit home shell;
      }
      extraConfig
    ];
  };
in
{
  inherit mkAppUser;
}
