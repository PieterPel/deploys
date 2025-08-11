{ self, inputs }:
let
  getSystem = hostname: inputs.dotfiles.nixosConfigurations.${hostname}.system;

  mkHost = hostname: modules: {
    nixosConfiguration = inputs.dotfiles.nixosConfigurations.${hostname}.extendModules {
      inherit modules;
    };
    deployNode = {
      inherit hostname;
      profiles.system = {
        user = "root";
        path =
          inputs.deploy-rs.lib.${getSystem hostname}.activate.nixos
            self.nixosConfigurations.${hostname};
      };
    };
  };

  mkProfile =
    hostname:
    { user
    , package
    , script ? "./bin/start"
    , profilePath ? null
    ,
    }:
    {
      inherit user;
      path = inputs.deploy-rs.lib.${getSystem hostname}.activate.custom package script;
    }
    // (if profilePath != null then { inherit profilePath; } else { });
in
{
  inherit mkHost mkProfile getSystem;
}
