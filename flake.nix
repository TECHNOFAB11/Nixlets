{
  outputs = {
    self,
    flake-parts,
    nixlet-lib,
    systems,
    ...
  } @ inputs:
    flake-parts.lib.mkFlake {inherit inputs;} {
      imports = [
        inputs.devenv.flakeModule
        inputs.nix-gitlab-ci.flakeModule
      ];
      systems = import systems;
      flake = {
        # █▄ █ █ ▀▄▀ █   █▀▀ ▀█▀ █▀
        # █ ▀█ █ █ █ █▄▄ ██▄  █  ▄█
        nixlets = with nixlet-lib; {
          mosquitto = mkNixlet ./nixlets/mosquitto;
          attic = mkNixlet ./nixlets/attic;
          postgres = mkNixlet ./nixlets/postgres;
          tikv = mkNixlet ./nixlets/tikv;
          surrealdb = mkNixlet ./nixlets/surrealdb;
        };
      };
      perSystem = {
        lib,
        pkgs,
        system,
        inputs',
        ...
      }: {
        imports = [
          ./ci.nix
        ];
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
            _: nixlet:
              nixlet.render {
                inherit system;
              }
          )
          self.nixlets;

        # allow directly building every nixlet with default values
        packages =
          builtins.mapAttrs (
            _: nixlet:
              nixlet.render {
                inherit system;
              }
          )
          self.nixlets;

        apps.upload = {
          type = "app";
          program = pkgs.callPackage nixlet-lib.uploadNixletsToGitlab {
            projectId = "55602785";
            nixlets = lib.attrValues self.nixlets;
          };
        };
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
    nix-gitlab-ci.url = "gitlab:TECHNOFAB/nix-gitlab-ci";

    kubenix = {
      url = "github:TECHNOFAB11/kubenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixlet-lib.url = "path:lib";
  };
}
