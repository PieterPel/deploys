{ self
, inputs
, hostname
, system
,
}:
let
  # NOTE:: deploy-rs now uses binary cache of nixpkgs
  pkgs = import inputs.nixpkgs { inherit system; };
  deployPkgs = import inputs.nixpkgs {
    inherit system;
    overlays = [
      inputs.deploy-rs.overlays.default
      (self: super: {
        deploy-rs = {
          inherit (pkgs) deploy-rs;
          lib = super.deploy-rs.lib;
        };
      })
    ];
  };

  # Helper function to extend a host form my dotfiles
  mkNixOS =
    modules:
    inputs.dotfiles.nixosConfigurations.${hostname}.extendModules {
      inherit modules;
    };

  remoteBuild = system != "x86_64-linux";

  # Default system profile for deployment
  systemProfile = {
    inherit remoteBuild;
    user = "root";
    sshUser = "deploy";
    path = deployPkgs.deploy-rs.lib.activate.nixos self.nixosConfigurations.${hostname};
  };

  # Helper function to generate an app profile for deploy-rs
  mkAppProfile =
    { user
    , package
    , sshUser ? "deploy"
    , script ? "./bin/start"
    , profilePath ? null
    ,
    }:
    {
      inherit user sshUser remoteBuild;
      path = deployPkgs.deploy-rs.lib.activate.custom package script;
    }
    // (if profilePath != null then { inherit profilePath; } else { });

  # Helper function to generate a node for deploy-rs
  mkNode =
    { hostname
    , profiles
    ,
    }:
    {
      inherit hostname remoteBuild;
      profiles = {
        system = systemProfile;
      }
      // profiles;
    };
in
{
  inherit mkNode mkAppProfile mkNixOS;
}
