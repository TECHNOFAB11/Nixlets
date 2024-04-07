{values, ...}: {
  kubernetes.resources = {
    services."${values.uniqueName}-pd" = {
      metadata.annotations."service.alpha.kubernetes.io/tolerate-unready-endpoints" = "true";
      spec = {
        selector.app = "${values.uniqueName}-pd";
        ports = [
          {
            name = "pd-server";
            port = values.pd.service.client_port;
          }
          {
            name = "peer";
            port = values.pd.service.peer_port;
          }
        ];
        type = values.pd.service.type;
        clusterIP = "None";
      };
    };
  };
}
