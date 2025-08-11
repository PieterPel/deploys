{ nixpkgs
, system
, compose2nix
, perhaps
, ...
}:
let

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
