{
  values,
  pkgs,
  ...
}: let
  tomlFormat = pkgs.formats.toml {};
in {
  kubernetes.resources = {
    configMaps."${values.uniqueName}-config" = {
      data = {
        "tikv.toml" = builtins.readFile (tomlFormat.generate "tikv.toml" values.tikv.config);
      };
    };
  };
}
