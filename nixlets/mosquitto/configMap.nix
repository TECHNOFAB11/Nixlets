{nixlet, ...}:
with nixlet; {
  kubernetes.resources = {
    configMaps."${values.uniqueName}-config" = {
      data = {
        "mosquitto.conf" = values.configContent;
      };
    };
  };
}
