{ self
, inputs
,
}:
let
  hostname = "nixberry";
  hostData = import ./host-data.nix;
  system = hostData.${hostname}.system;
  helpers = import ../helpers/system.nix {
    inherit
      self
      inputs
      hostname
      system
      ;
  };
  perhapsPackage = import ../derivations/perhaps.nix {
    inherit system inputs;
  };
  perhaps = helpers.mkAppProfile {
    user = "perhaps";
    package = perhapsPackage.package;
  };

in
{
  nixosConfiguration = helpers.mkNixOS [ ../modules ];
  node = helpers.mkNode {
    hostname = hostData.${hostname}.ip;
    profiles = {
      inherit perhaps;
    };
  };
}
