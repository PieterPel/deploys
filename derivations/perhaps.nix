{ self
, inputs
, hostname
, ...
}:
let
  systemHelpers = import ../helpers/system.nix { inherit self inputs; };

  system = systemHelpers.getSystem hostname;

  pkgs = inputs.pkgs.legacyPackages.${system};

  compose2nix = inputs.compose2nix.packages.${system}.default;

  composeHelpers = import ../helpers/compose.nix { inherit pkgs compose2nix; };

  composeFile = inputs.perhaps.outPath + "docker-compose.yml";
in
{
  package = composeHelpers.mkComposeApp {
    name = "perhaps";
    composeFile = composeFile;
  };
}
