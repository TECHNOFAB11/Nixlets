{
  pkgs,
  inputs',
  ...
}: {
  ci = {
    stages = ["check"];
    default = {
      retry = {
        max = 2;
        when = "runner_system_failure";
      };
    };
    jobs = {
      "check" = {
        stage = "check";
        script = [
          "nix flake check --impure"
        ];
      };
    };
  };
}
