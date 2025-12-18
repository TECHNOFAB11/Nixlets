{
  pkgs,
  ntlib,
  nixlet-lib,
  ...
}: {
  suites."Lib Tests" = {
    pos = __curPos;
    tests = let
      nixlet = nixlet-lib.mkNixlet ./fixtures/example;
    in [
      {
        name = "mkNixlet fail on nonexistant nixlet.nix";
        expected = {
          success = false;
          value = false;
        };
        actual = builtins.tryEval (nixlet-lib.mkNixlet "/nonexistant").name;
      }
      {
        name = "mkNixlet success";
        expected = {
          name = "example";
          version = "0.0.1";
          description = "hello world";
        };
        actual = {inherit (nixlet) name description version;};
      }
      {
        name = "Nixlet mkDocs";
        type = "script";
        script = let
          docs = nixlet.mkDocs {};
        in
          # sh
          ''
            ${ntlib.helpers.path [pkgs.gnugrep]}
            ${ntlib.helpers.scriptHelpers}
            assert "-f ${docs}" "generated the file"
            assert_file_contains "${docs}" '`example`'
            assert_file_contains "${docs}" "Some description."
            assert_file_contains "${docs}" '"Hello world!"'
          '';
      }
    ];
  };
}
