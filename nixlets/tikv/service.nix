{values, ...}: {
  kubernetes.resources = {
    services = {
      /*
      PD HEADLESS SERVICE
      */
      "${values.uniqueName}-pd".spec = {
        selector.app = "${values.uniqueName}-pd";
        ports = [
          {
            name = "pd-server";
            port = values.pd.service.port;
          }
          {
            name = "peer";
            port = values.pd.service.peer_port;
          }
        ];
        type = "ClusterIP";
        clusterIP = "None";
        publishNotReadyAddresses = true;
      };
      /*
      TIKV HEADLESS SERVICE
      */
      "${values.uniqueName}-peer".spec = {
        selector.app = "${values.uniqueName}";
        ports = [
          {
            name = "peer";
            port = values.tikv.service.port;
          }
        ];
        type = "ClusterIP";
        clusterIP = "None";
        publishNotReadyAddresses = true;
      };
      /*
      CLUSTER SERVICE
      */
      "${values.uniqueName}".spec = {
        selector.app = "${values.uniqueName}-pd";
        ports = [
          {
            name = "server";
            port = values.pd.service.port;
          }
        ];
        type = values.pd.service.type;
      };
    };
  };
}
