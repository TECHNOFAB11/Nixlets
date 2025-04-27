{
  ci = {
    stages = ["check" "build" "deploy"];
    jobs = {
      "check" = {
        stage = "check";
        script = [
          "nix flake check --impure"
        ];
      };
      "docs" = {
        stage = "build";
        script = [
          # sh
          ''
            nix build .#docs:default
            mkdir -p public
            cp -r result/. public/
          ''
        ];
        artifacts.paths = ["public"];
      };
      "pages" = {
        nix.enable = false;
        image = "alpine:latest";
        stage = "deploy";
        script = ["true"];
        artifacts.paths = ["public"];
        rules = [
          {
            "if" = "$CI_COMMIT_BRANCH == $CI_DEFAULT_BRANCH";
          }
        ];
      };
      "upload" = {
        stage = "deploy";
        rules = [
          {"if" = ''$CI_COMMIT_REF_NAME == "main"'';}
        ];
        variables.AUTH_HEADER = "JOB-TOKEN: \${CI_JOB_TOKEN}";
        script = [
          "nix run .#upload --impure"
        ];
      };
    };
  };
}
