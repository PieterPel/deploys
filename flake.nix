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
      platforms = {
        nixberry = "aarch64-linux";
      };

      helpers = import ./helpers/system.nix {
        inherit self platforms;
        dotfiles = inputs.dotfiles;
        deploy-rs = inputs.deploy-rs;
      };

      hosts = {
        nixberry = helpers.mkHost "nixberry" [
          ./modules
        ];
      };

      perhaps = import ./derivations/perhaps.nix {
        nixpkgs = inputs.nixpkgs;
        system = platforms.nixberry;
        compose2nix = inputs.compose2nix;
        perhaps = inputs.perhaps;
      };

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

      deployChecks = builtins.mapAttrs
        (
          system: deployLib: deployLib.deployChecks self.deploy
        )
        inputs.deploy-rs.lib;

      supportedSystems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];

      forAllSystems = inputs.nixpkgs.lib.genAttrs supportedSystems;

      lib = inputs.nixpkgs.lib;
    in
    {
      # General setup for all our hosts
      nixosConfigurations = builtins.mapAttrs (_: host: host.nixosConfiguration) hosts;

      deploy.nodes = lib.recursiveUpdate (builtins.mapAttrs (_: host: host.deployNode) hosts) {
        nixberry = lib.recursiveUpdate (hosts.nixberry.deployNode) {
          profiles = {
            perhaps = helpers.mkProfile {
              hostname = "nixberry";
              user = "perhaps";
              package = perhaps.package;
            };
          };
        };
      };

      # Combine pre-commit and deploy-rs checks
      checks = inputs.nixpkgs.lib.recursiveUpdate preCommitChecks deployChecks;

      # devShells for all systems
      devShells = forAllSystems (system: {
        default = inputs.nixpkgs.legacyPackages.${system}.mkShell {
          inherit (self.checks.${system}.pre-commit-check) shellHook;
          buildInputs = self.checks.${system}.pre-commit-check.enabledPackages;
        };
      });

      # And add a formatter
      formatter = forAllSystems (system: inputs.nixpkgs.legacyPackages.${system}.nixpkgs-fmt);

      perhaps = perhaps; # NOTE: may as well do this
    };
}
