{
  outputs = {
    self,
    nixpkgs,
    flake-parts,
    systems,
    ...
  } @ inputs: let
    nixlet-lib = import ./lib {
      inherit (nixpkgs) lib;
      inherit (inputs) kubenix;
    };
  in
    flake-parts.lib.mkFlake {inherit inputs;} {
      imports = [
        inputs.devenv.flakeModule
        inputs.nix-gitlab-ci.flakeModule
        inputs.treefmt-nix.flakeModule
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
        config,
        system,
        ...
      }: {
        imports = [
          ./ci.nix
        ];
        treefmt = {
          projectRootFile = "flake.nix";
          programs = {
            alejandra.enable = true;
            mdformat.enable = true;
          };
        };
        devenv.shells.default = {
          containers = lib.mkForce {};
          packages = with pkgs; [
            kube-linter
          ];

          pre-commit.hooks.treefmt = {
            enable = true;
            packageOverrides.treefmt = config.treefmt.build.wrapper;
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
      inputs.git-hooks.follows = "git-hooks";
    };
    git-hooks.url = "github:cachix/git-hooks.nix";
    treefmt-nix.url = "github:numtide/treefmt-nix";
    nix-gitlab-ci.url = "gitlab:TECHNOFAB/nix-gitlab-ci?dir=lib";

    kubenix = {
      url = "github:TECHNOFAB11/kubenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  nixConfig = {
    extra-trusted-public-keys = "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw=";
    extra-substituters = "https://devenv.cachix.org";
  };
}
