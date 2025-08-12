{ inputs
, system
,
}:
let

  pkgs = inputs.nixpkgs.legacyPackages.${system};

  compose2nixPackage = inputs.compose2nix.packages.${system}.default;

  composeHelpers = import ../helpers/compose.nix {
    inherit pkgs;
    compose2nix = compose2nixPackage;
  };

  composeFile = "${inputs.perhaps.outPath}/docker-compose.yml";
in
{
  package = composeHelpers.mkComposeApp {
    name = "perhaps";
    composeFile = composeFile;
  };
}
