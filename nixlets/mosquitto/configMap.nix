{values, ...}: {
  kubernetes.resources = {
    configMaps."${values.uniqueName}-config" = {
      data = {
        "mosquitto.conf" = values.configContent;
      };
    };
  };
}
