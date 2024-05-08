{nixlet, ...}:
with nixlet; {
  kubernetes.resources = {
    services."${values.uniqueName}" = {
      spec = {
        selector.app = "${values.uniqueName}";
        ports = [
          {
            name = "tcp";
            port = values.service.port;
            targetPort = 5432;
          }
        ];
        type = values.service.type;
      };
    };
  };
}
