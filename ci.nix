{
  pkgs,
  inputs',
  ...
}: {
  ci = {
    stages = ["check" "upload"];
    default = {
      retry = {
        max = 2;
        when = "runner_system_failure";
      };
    };
    jobs = {
      "check" = {
        stage = "check";
        before_script = [
          "nix flake prefetch path:lib"
        ];
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
        before_script = [
          "nix flake prefetch path:lib"
        ];
        script = [
          "nix run .#upload --impure"
        ];
      };
    };
  };
}
