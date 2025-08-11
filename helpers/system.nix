{ self
, dotfiles
, deploy-rs
,
}:
let
  mkHost = hostname: system: modules: {
    nixosConfiguration = dotfiles.nixosConfigurations.${hostname}.extendModules {
      inherit modules;
    };
    deployNode = {
      inherit hostname;
      profiles.system = {
        user = "root";
        path = deploy-rs.lib.${system}.activate.nixos self.nixosConfigurations.${hostname};
      };
    };
  };

  mkProfile =
    hostname: system:
    { user
    , package
    , script ? "./bin/start"
    , profilePath ? null
    ,
    }:
    {
      inherit user;
      path = deploy-rs.lib.${system}.activate.custom package script;
    }
    // (if profilePath != null then { inherit profilePath; } else { });
in
{
  inherit mkHost mkProfile;
}
