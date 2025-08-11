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
      hostsData = {
        nixberry = {
          ip = "192.168.1.10";
        };
      };

      helpers = import ./helpers/system.nix { inherit self inputs; };

      hosts = {
        nixberry = helpers.mkHost "nixberry" [
          ./modules
          {
            hosts = hostsData;
            logsHoster = "nixberry";
            perhapsHoster = "nixberry";
          }
        ];
      };

      perhaps = import ./derivations/perhaps.nix {
        inherit self inputs;
        hostname = "nixberry";
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

    in
    {
      # General setup for all our hosts
      nixosConfigurations = builtins.mapAttrs (_: host: host.nixosConfiguration) hosts;
      deploy.nodes = builtins.mapAttrs (_: host: host.deployNode) hosts;

      # Define what should be deployed where using profiles
      deploys.nodes.nixberry.profiles.perhaps = helpers.mkProfile "nixberry" {
        user = "perhaps";
        package = perhaps.package;
      };

      # Combine pre-commit and eploy-rs checks
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
    };
}
