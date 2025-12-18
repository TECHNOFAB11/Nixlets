{nixlet, ...}:
with nixlet; {
  kubernetes.resources = {
    services."${values.uniqueName}" = {
      spec = {
        selector.app = "${values.uniqueName}";
        ports = [
          {
            name = "tcp";
            inherit (values.service) port;
            targetPort = 5432;
          }
        ];
        inherit (values.service) type;
      };
    };
  };
}
