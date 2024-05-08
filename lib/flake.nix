{
  description = "Nixlets lib";

  outputs = {
    self,
    nixpkgs,
    kubenix,
    ...
  } @ inputs:
    import ./. {
      inherit (nixpkgs) lib;
      inherit inputs;
    };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    kubenix = {
      url = "github:TECHNOFAB11/kubenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
}
