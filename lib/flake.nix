{
  description = "Nixlets lib";

  outputs = {
    nixpkgs,
    kubenix,
    ...
  }:
    import ./. {
      inherit (nixpkgs) lib;
      inherit kubenix;
    };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    kubenix = {
      url = "github:TECHNOFAB11/kubenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
}
