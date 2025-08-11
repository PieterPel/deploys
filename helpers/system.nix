{ self
, dotfiles
, deploy-rs
, platforms
,
}:
let
  mkHost = hostname: modules: {
    nixosConfiguration = dotfiles.nixosConfigurations.${hostname}.extendModules {
      inherit modules;
    };
    deployNode = {
      # inherit hostname;
      hostname = "192.168.178.101";
      profiles.system = {
        user = "root";
        sshUser = "deploy";
        path = deploy-rs.lib.${platforms.${hostname}}.activate.nixos self.nixosConfigurations.${hostname};
      };
    };
  };

  mkProfile =
    { hostname
    , user
    , package
    , sshUser ? "deploy"
    , script ? "./bin/start"
    , profilePath ? null
    ,
    }:
    let
      system = platforms.${hostname};
    in
    {
      inherit user;
      inherit sshUser;
      path = deploy-rs.lib.${system}.activate.custom package script;
      remoteBuild = system != "x86_64-linux";
    }
    // (if profilePath != null then { inherit profilePath; } else { });
in
{
  inherit mkHost mkProfile;
}
