{values, ...}: {
  kubernetes.resources = {
    configMaps."${values.uniqueName}-config" = {
      data = {
        "config.toml" = values.configToml;
      };
    };
  };
}
