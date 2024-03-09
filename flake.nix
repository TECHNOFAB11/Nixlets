{
  outputs = {
    self,
    flake-parts,
    systems,
    ...
  } @ inputs:
    flake-parts.lib.mkFlake {inherit inputs;} {
      imports = [
        inputs.devenv.flakeModule
      ];
      systems = import systems;
      flake = rec {
        utils = import ./lib {
          inherit (inputs.nixpkgs) lib;
          inherit inputs;
        };

        # █▄░█ █ ▀▄▀ █░░ █▀▀ ▀█▀ █▀
        # █░▀█ █ █░█ █▄▄ ██▄ ░█░ ▄█
        nixlets = {
          # <name> = utils.mkNixlet ./nixlets/<name>;
          mosquitto = utils.mkNixlet ./nixlets/mosquitto;
          attic = utils.mkNixlet ./nixlets/attic;
          postgres = utils.mkNixlet ./nixlets/postgres;
        };
      };
      perSystem = {
        pkgs,
        system,
        inputs',
        ...
      }: {
        formatter = pkgs.alejandra;
        devenv.shells.default = {
          containers = pkgs.lib.mkForce {};
          packages = with pkgs; [
            kube-linter
          ];

          pre-commit = {
            hooks = {
              alejandra.enable = true;
            };
          };
        };

        # check if every nixlet successfully renders with default values
        checks =
          builtins.mapAttrs (
            name: nixlet:
              self.utils.renderNixlet {
                inherit system nixlet;
                project = name;
                values = {};
              }
          )
          self.nixlets;

        # allow directly building every nixlet with default values
        packages =
          builtins.mapAttrs (
            name: nixlet:
              self.utils.renderNixlet {
                inherit system nixlet;
                project = name;
                values = {};
              }
          )
          self.nixlets;
      };
    };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    # flake & devenv related
    flake-parts.url = "github:hercules-ci/flake-parts";
    systems.url = "github:nix-systems/default-linux";
    devenv = {
      url = "github:cachix/devenv";
      inputs.pre-commit-hooks.follows = "pre-commit-hooks";
    };
    pre-commit-hooks.url = "github:cachix/pre-commit-hooks.nix";

    kubenix = {
      url = "github:hall/kubenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
}
