{ lib
, pkgs
, config
, ...
}:

let
  userHelper = import ../helpers/user.nix { inherit lib pkgs; };
in
{
  config = lib.mkIf config.derived.hostPerhaps (
    userHelper.mkAppUser {
      name = "perhaps";
    }
  );
}
