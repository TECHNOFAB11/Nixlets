{nixlet, ...}:
with nixlet; {
  kubernetes.resources = {
    services."${values.uniqueName}" = {
      spec = {
        selector.app = "${values.uniqueName}";
        ports = [
          {
            name = "http";
            port = 8080;
          }
        ];
        inherit (values.service) type;
      };
    };
  };
}
