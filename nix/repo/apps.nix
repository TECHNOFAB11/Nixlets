{
  inputs,
  cell,
  ...
}: let
  inherit (inputs) pkgs nixlet-lib;
  inherit (cell) nixlets;
in {
  upload = {
    type = "app";
    program =
      (pkgs.callPackage nixlet-lib.uploadNixletsToGitlab {
        projectId = "55602785";
        nixlets = builtins.attrValues nixlets;
      })
      + "/bin/nixlets-upload";
  };
}
