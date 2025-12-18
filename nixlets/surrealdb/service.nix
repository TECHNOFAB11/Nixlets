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
            inherit (values.service) port;
          }
        ];
        inherit (values.service) type;
      };
    };
  };
}
