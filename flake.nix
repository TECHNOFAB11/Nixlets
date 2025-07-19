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
          settings.formatter.mdformat.command = let
            pkg = pkgs.python3.withPackages (p: [
              p.mdformat
              p.mdformat-mkdocs
            ]);
          in
            lib.mkForce "${pkg}/bin/mdformat";
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
          deps = pp: [
            pp.mkdocs-material
            (pp.callPackage inputs.mkdocs-material-umami {})
            (pp.buildPythonPackage rec {
              pname = "mkdocs-gen-files";
              version = "0.5.0";
              pyproject = true;
              build-system = [pp.hatchling];
              src = pkgs.fetchFromGitHub {
                owner = "oprypin";
                repo = "mkdocs-gen-files";
                rev = "v${version}";
                hash = "sha256-nRRdY7/en42s4PmHH+9vccRIl4pIp1F/Ka1bYvSHpBw=";
              };
              dependencies = [pp.mkdocs];
            })
          ];
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
            plugins = [
              "search"
              "material-umami"
              {
                # bit hacky, but works :D
                "gen-files".scripts = let
                  docsEntries = builtins.toJSON (builtins.mapAttrs (n: v: v.mkDocs {}) self.nixlets);
                in [
                  (builtins.toFile "gen.py"
                    # py
                    ''
                      import mkdocs_gen_files, json
                      data = json.loads('${docsEntries}')
                      for name, file in data.items():
                        with open(file, 'r') as infile:
                          content = infile.read()
                        with mkdocs_gen_files.open(f"options/{name}.md", "w") as outfile:
                          outfile.write(content)
                    '')
                ];
              }
            ];
            nav = [
              {"Introduction" = "index.md";}
              {"Creating Nixlets" = "creation.md";}
              {"Packaging" = "packaging.md";}
              {"Usage" = "usage.md";}
              {"Secrets" = "secrets.md";}
              {
                "Nixlets Values" =
                  lib.mapAttrsToList (n: v: {
                    ${v.name} = "options/${n}.md";
                  })
                  self.nixlets;
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
              "admonition"
            ];
            extra.analytics = {
              provider = "umami";
              site_id = "a4181010-317a-45e3-978c-5d07a93e0cd2";
              src = "https://analytics.tf/umami";
              domains = "nixlets.projects.tf";
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
    nix-gitlab-ci.url = "gitlab:TECHNOFAB/nix-gitlab-ci/2.1.0?dir=lib";
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
