{ self
, inputs
, hostname
, system
,
}:
let

  mkNixOS =
    modules:
    inputs.dotfiles.nixosConfigurations.${hostname}.extendModules {
      inherit modules;
    };

  # mkNode = ipaddress: {
  #   hostname = ipaddress;
  #   profiles.system = {
  #     user = "root";
  #     sshUser = "deploy";
  #     path = inputs.deploy-rs.lib.${system}.activate.nixos self.nixosConfigurations.${hostname};
  #   };
  # };
  #
  systemProfile = {
    user = "root";
    sshUser = "deploy";
    path = inputs.deploy-rs.lib.${system}.activate.nixos self.nixosConfigurations.${hostname};
  };

  mkAppProfile =
    { user
    , package
    , sshUser ? "deploy"
    , script ? "./bin/start"
    , profilePath ? null
    ,
    }:
    {
      inherit user;
      inherit sshUser;
      path = inputs.deploy-rs.lib.${system}.activate.custom package script;
      remoteBuild = system != "x86_64-linux";
    }
    // (if profilePath != null then { inherit profilePath; } else { });

  mkNode =
    { hostname
    , profiles
    ,
    }:
    {
      inherit hostname;
      profiles = {
        system = systemProfile;
      }
      // profiles;
    };
in
{
  inherit mkNode mkAppProfile mkNixOS;
}
