{nixlet, ...}:
with nixlet; {
  kubernetes.resources = {
    services."${values.uniqueName}" = {
      spec = {
        selector.app = "${values.uniqueName}";
        ports = [
          {
            name = "mqtt";
            port = values.service.port;
            targetPort = 1883;
          }
        ];
        type = values.service.type;
      };
    };
  };
}
