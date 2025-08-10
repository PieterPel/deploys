{
  inputs = {
    deploy-rs = {
      url = "github:serokell/deploy-rs";
    };
    dotfiles = {
      url = "github:PieterPel/dotfiles";
    };
    perhaps = {
      url = "github:PieterPel/perhaps";
    };
  };

  outputs =
    { self, ... }@inputs:

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

      hosts = {
        nixberry = mkHost "nixberry" [ ];
      };

      mkProfile = hostname: { user, package, script ? "./bin/start", profilePath ? null }: 
        {
          inherit user;
          path = inputs.deploy-rs.lib.${getSystem hostname}.activate.custom package script;
        } // (if profilePath != null then { inherit profilePath; } else {});
    in
    {
      # General setup for all our hosts
      nixosConfigurations = builtins.mapAttrs (_: host: host.nixosConfiguration) hosts;
      deploy.nodes = builtins.mapAttrs (_: host: host.deployNode) hosts;

      # Define what should be deployed where using profiles
      deploys.nodes.nixberry.profiles.perhaps = mkProfile "nixberry" {
        user = "root";
        package = inputs.perhaps;
      };

      # Inbuilt checks by deploy-rs
      checks = builtins.mapAttrs (
        system: deployLib: deployLib.deployChecks self.deploy
      ) inputs.deploy-rs.lib;
    };
}
