{values, ...}: {
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
        type = values.service.type;
      };
    };
  };
}
