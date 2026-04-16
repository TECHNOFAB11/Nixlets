{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    ren.url = "gitlab:rensa-nix/core/v0.2.0?dir=lib";
    kubenix = {
      url = "github:TECHNOFAB11/kubenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    ren,
    ...
  } @ inputs:
    ren.buildWith
    {
      inherit inputs;
      cellsFrom = ./nix;
      transformInputs = system: i:
        i
        // {
          pkgs = import i.nixpkgs {inherit system;};
        };
    }
    {
      packages = ren.select self [
        ["repo" "ci" "packages"]
        ["repo" "docs"]
        ["repo" "soonix" "packages"]
        ["repo" "tests"]
      ];
      apps = ren.select self ["repo" "apps"];
      nixlets = ren.get self ["repo" "nixlets"];
    };
}
