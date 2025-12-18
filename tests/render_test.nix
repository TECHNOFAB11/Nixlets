{
  pkgs,
  ntlib,
  system,
  nixlets,
  ...
}: {
  suites."Render Tests" = {
    pos = __curPos;
    tests = builtins.map (
      nixlet: {
        name = "render ${nixlet.name}";
        type = "script";
        script = let
          output = nixlet.render {inherit system;};
        in
          # sh
          ''
            ${ntlib.helpers.path [pkgs.gnugrep]}
            ${ntlib.helpers.scriptHelpers}

            assert "-f ${output}" "should render"
            assert_file_contains "${output}" "apiVersion"
            assert_file_contains "${output}" "kubenix/k8s-version"
            assert_file_contains "${output}" "kubenix/project-name"
          '';
      }
    ) (builtins.attrValues nixlets);
  };
}
