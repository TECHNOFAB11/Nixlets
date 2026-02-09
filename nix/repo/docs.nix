{
  inputs,
  cell,
  ...
}: let
  inherit (inputs) pkgs doclib nixlet-lib;
  inherit (cell) nixlets;

  optionsDoc = doclib.mkOptionDocs {
    module = nixlet-lib.nixletModule;
    roots = [
      {
        url = "https://gitlab.com/TECHNOFAB/nixlets/-/blob/main/lib";
        path = "${inputs.self}/lib";
      }
    ];
  };
  optionsDocs = pkgs.runCommand "options-docs" {} ''
    mkdir -p $out
    ln -s ${optionsDoc} $out/options.md
  '';
in
  (doclib.mkDocs {
    docs."default" = {
      base = "${inputs.self}";
      path = "${inputs.self}/docs";
      material = {
        enable = true;
        colors = {
          primary = "blue";
          accent = "light blue";
        };
        umami = {
          enable = true;
          src = "https://analytics.tf/umami";
          siteId = "a4181010-317a-45e3-978c-5d07a93e0cd2";
          domains = ["nixlets.projects.tf"];
        };
      };
      macros = {
        enable = true;
        includeDir = toString optionsDocs;
      };
      dynamic-nav = {
        enable = true;
        files."Nixlets Values" = builtins.map (val: {${val.name} = val.mkDocs {fullValues = true;};}) (builtins.attrValues nixlets);
      };
      config = {
        site_name = "Nixlets";
        site_url = "https://nixlets.projects.tf";
        repo_name = "TECHNOFAB/nixlets";
        repo_url = "https://gitlab.com/TECHNOFAB/nixlets";
        extra_css = ["style.css"];
        theme = {
          logo = "images/logo.svg";
          icon.repo = "simple/gitlab";
          favicon = "images/logo.svg";
        };
        nav = [
          {"Introduction" = "index.md";}
          {"Creating Nixlets" = "creation.md";}
          {"Packaging" = "packaging.md";}
          {"Usage" = "usage.md";}
          {"Generating Docs" = "generating_docs.md";}
          {"Secrets" = "secrets.md";}
          {"Options" = "options.md";}
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
      };
    };
  })
  .packages
