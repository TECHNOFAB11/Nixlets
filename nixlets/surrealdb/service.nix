{nixlet, ...}:
with nixlet; {
  kubernetes.resources = {
    services."${values.uniqueName}" = {
      spec = {
        selector.app = "${values.uniqueName}";
        ports = [
          {
            name = "http";
            targetPort = "http";
            port = values.service.port;
          }
        ];
        type = values.service.type;
      };
    };
  };
}
