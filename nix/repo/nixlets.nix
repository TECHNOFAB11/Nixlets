{inputs, ...}: let
  inherit (inputs) self nixlet-lib;
in
  import "${self}/nixlets" {inherit nixlet-lib;}
