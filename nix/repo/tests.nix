{
  inputs,
  cell,
  system,
  ...
}: let
  inherit (inputs) pkgs ntlib nixlet-lib;
  inherit (cell) nixlets;
in {
  tests = ntlib.mkNixtest {
    modules = ntlib.autodiscover {dir = "${inputs.self}/tests";};
    args = {
      inherit pkgs ntlib nixlet-lib nixlets system;
    };
  };
}
