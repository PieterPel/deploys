{
  inputs = {
    nixpkgs = {
      url = "github:nixos/nixpkgs?ref=nixos-unstable";
    };
    deploy-rs = {
      url = "github:serokell/deploy-rs";
    };
    dotfiles = {
      url = "github:PieterPel/dotfiles";
    };
    perhaps = {
      url = "github:PieterPel/perhaps";
    };
    compose2nix = {
      url = "github:aksiksi/compose2nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    pre-commit-hooks = {
      url = "github:cachix/git-hooks.nix";
    };
  };

  outputs =
    { self, ... }@inputs:

    let
      preCommitChecks = forAllSystems (system: {
        pre-commit-check = inputs.pre-commit-hooks.lib.${system}.run {
          src = ./.;
          hooks = {
            nixpkgs-fmt.enable = true;
            nil.enable = true;
            flake-checker.enable = true;
          };
        };
      });

      lib = inputs.nixpkgs.lib;
      hostData = import ./nodes/host-data.nix;

      deployChecks = forAllSystems (
        system:
        let
          nodesForSystem = lib.filterAttrs (name: _: hostData.${name}.system == system) self.deploy.nodes;
        in
        if nodesForSystem != { } then
          inputs.deploy-rs.lib.${system}.deployChecks { nodes = nodesForSystem; }
        else
          { }
      );

      supportedSystems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];

      forAllSystems = inputs.nixpkgs.lib.genAttrs supportedSystems;

      nixberry = import ./nodes/nixberry.nix {
        inherit self inputs;
      };
    in
    {
      # Construct our flake output for deployment
      nixosConfigurations = {
        nixberry = nixberry.nixosConfiguration;
      };
      deploy.nodes = {
        nixberry = nixberry.node;
      };

      # # Combine pre-commit and deploy-rs checks
      checks = lib.recursiveUpdate preCommitChecks deployChecks;

      # devShells for all systems
      devShells = forAllSystems (system: {
        default = inputs.nixpkgs.legacyPackages.${system}.mkShell {
          inherit (self.checks.${system}.pre-commit-check) shellHook;
          buildInputs = self.checks.${system}.pre-commit-check.enabledPackages;
        };
      });

      # And add a formatter
      formatter = forAllSystems (system: inputs.nixpkgs.legacyPackages.${system}.nixpkgs-fmt);
    };
}
