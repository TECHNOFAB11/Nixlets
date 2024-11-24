{
  ci = {
    stages = ["check" "upload"];
    jobs = {
      "check" = {
        stage = "check";
        script = [
          "nix flake check --impure"
        ];
      };
      "upload" = {
        stage = "upload";
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
