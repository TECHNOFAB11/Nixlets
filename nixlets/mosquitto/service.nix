{nixlet, ...}:
with nixlet; {
  kubernetes.resources = {
    services."${values.uniqueName}" = {
      spec = {
        selector.app = "${values.uniqueName}";
        ports = [
          {
            name = "mqtt";
            inherit (values.service) port;
            targetPort = 1883;
          }
        ];
        inherit (values.service) type;
      };
    };
  };
}
