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
        inputs.nix-mkdocs.flakeModule
        inputs.treefmt-nix.flakeModule
      ];
      systems = import systems;
      flake = {
        nixlets = import ./nixlets {inherit nixlet-lib;};
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

        doc = {
          path = ./docs;
          deps = pp: [pp.mkdocs-material (pp.callPackage inputs.mkdocs-material-umami {})];
          config = {
            site_name = "Nixlets";
            repo_name = "TECHNOFAB/nixlets";
            repo_url = "https://gitlab.com/TECHNOFAB/nixlets";
            edit_uri = "edit/main/docs/";
            theme = {
              name = "material";
              features = ["content.code.copy" "content.action.edit"];
              icon.repo = "simple/gitlab";
              logo = "images/logo.png";
              favicon = "images/favicon.png";
              palette = [
                {
                  scheme = "default";
                  media = "(prefers-color-scheme: light)";
                  primary = "blue";
                  accent = "light blue";
                  toggle = {
                    icon = "material/brightness-7";
                    name = "Switch to dark mode";
                  };
                }
                {
                  scheme = "slate";
                  media = "(prefers-color-scheme: dark)";
                  primary = "blue";
                  accent = "light blue";
                  toggle = {
                    icon = "material/brightness-4";
                    name = "Switch to light mode";
                  };
                }
              ];
            };
            plugins = ["search" "material-umami"];
            nav = [
              {
                "Introduction" = "index.md";
              }
            ];
            markdown_extensions = [
              {
                "pymdownx.highlight".pygments_lang_class = true;
              }
              "pymdownx.inlinehilite"
              "pymdownx.snippets"
              "pymdownx.superfences"
              "fenced_code"
            ];
            extra.analytics = {
              provider = "umami";
              site_id = "a4181010-317a-45e3-978c-5d07a93e0cd2";
              src = "https://analytics.tf/umami";
              feedback = {
                title = "Was this page helpful?";
                ratings = [
                  {
                    icon = "material/thumb-up-outline";
                    name = "This page is helpful";
                    data = "good";
                    note = "Thanks for your feedback!";
                  }
                  {
                    icon = "material/thumb-down-outline";
                    name = "This page could be improved";
                    data = "bad";
                    note = "Thanks for your feedback!";
                  }
                ];
              };
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
      inputs.git-hooks.follows = "git-hooks";
    };
    git-hooks.url = "github:cachix/git-hooks.nix";
    treefmt-nix.url = "github:numtide/treefmt-nix";
    nix-gitlab-ci.url = "gitlab:TECHNOFAB/nix-gitlab-ci/feat/v2?dir=lib";
    nix-mkdocs.url = "gitlab:TECHNOFAB/nixmkdocs?dir=lib";
    mkdocs-material-umami.url = "gitlab:technofab/mkdocs-material-umami";

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
