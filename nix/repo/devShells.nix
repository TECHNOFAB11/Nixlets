{
  cell,
  inputs,
  ...
}: let
  inherit (inputs) pkgs devshell treefmt;
  inherit (cell) soonix;
in {
  default = devshell.mkShell {
    imports = [soonix.devshellModule];
    packages = [
      pkgs.nil
      (treefmt.mkWrapper pkgs {
        programs = {
          alejandra.enable = true;
          deadnix.enable = true;
          statix.enable = true;
          mdformat.enable = true;
        };
        settings.formatter.mdformat.command = let
          pkg = pkgs.python3.withPackages (p: [
            p.mdformat
            p.mdformat-mkdocs
          ]);
        in "${pkg}/bin/mdformat";
      })
    ];
  };
}
