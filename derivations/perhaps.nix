{ self
, nixpkgs
, dotfiles
, deploy-rs
, hostname
, compose2nix
, perhaps
, ...
}:
let
  systemHelpers = import ../helpers/system.nix {
    inherit self dotfiles deploy-rs;
  };

  system = systemHelpers.getSystem hostname;

  pkgs = nixpkgs.legacyPackages.${system};

  compose2nixPackage = compose2nix.packages.${system}.default;

  composeHelpers = import ../helpers/compose.nix {
    inherit pkgs;
    compose2nix = compose2nixPackage;
  };

  composeFile = perhaps.outPath + "docker-compose.yml";
in
{
  package = composeHelpers.mkComposeApp {
    name = "perhaps";
    composeFile = composeFile;
  };
}
