{values, ...}: {
  kubernetes.resources = {
    /*
    Placement Driver
    */
    statefulSets."${values.uniqueName}-pd".spec = {
      replicas = values.pd.replicaCount;
      selector.matchLabels.name = "${values.uniqueName}-pd";
      serviceName = "${values.uniqueName}-pd";
      updateStrategy.type = "RollingUpdate";
      podManagementPolicy = "Parallel";
      template = {
        metadata.labels = rec {
          name = "${values.uniqueName}-pd";
          app = name;
        };
        spec = {
          containers."pd" = {
            image = "${values.pd.image.repository}:${values.pd.image.tag}";
            imagePullPolicy = values.pd.image.pullPolicy;
            env = [
              {
                name = "HEADLESS_SERVICE_NAME";
                value = "${values.uniqueName}-pd";
              }
              {
                name = "NAMESPACE";
                valueFrom.fieldRef.fieldPath = "metadata.namespace";
              }
            ];
            ports = {
              "pd-server".containerPort = values.pd.service.port;
              "peer".containerPort = values.pd.service.peer_port;
            };
            command = [
              "/bin/sh"
              "-ecx"
              ''
                PEERS=""
                for i in $(seq 0 $((${builtins.toString values.pd.replicaCount} - 1))); do
                  PEERS="''${PEERS}''${PEERS:+,}''${HEADLESS_SERVICE_NAME}-''${i}=http://''${HEADLESS_SERVICE_NAME}-''${i}.''${HEADLESS_SERVICE_NAME}.''${NAMESPACE}.svc:${builtins.toString values.pd.service.peer_port}"
                done

                /pd-server --name=''${HOSTNAME} \
                  --client-urls=http://0.0.0.0:${builtins.toString values.pd.service.port} \
                  --advertise-client-urls=http://''${HOSTNAME}.''${HEADLESS_SERVICE_NAME}.''${NAMESPACE}.svc:${builtins.toString values.pd.service.port} \
                  --peer-urls=http://0.0.0.0:${builtins.toString values.pd.service.peer_port} \
                  --advertise-peer-urls=http://''${HOSTNAME}.''${HEADLESS_SERVICE_NAME}.''${NAMESPACE}.svc:${builtins.toString values.pd.service.peer_port} \
                  --data-dir /var/lib/pd \
                  --initial-cluster ''${PEERS}
              ''
            ];
            volumeMounts."data" = {
              name = "${values.uniqueName}-pd-data";
              mountPath = "/var/lib/pd";
            };
          };
        };
      };
      volumeClaimTemplates = [
        {
          metadata.name = "${values.uniqueName}-pd-data";
          spec = {
            accessModes = ["ReadWriteOnce"];
            resources.requests.storage = values.pd.storage;
          };
        }
      ];
    };

    /*
    TiKV
    */
    statefulSets."${values.uniqueName}".spec = {
      replicas = values.tikv.replicaCount;
      selector.matchLabels.name = "${values.uniqueName}";
      serviceName = "${values.uniqueName}-peer";
      updateStrategy.type = "RollingUpdate";
      podManagementPolicy = "Parallel";
      template = {
        metadata.labels = rec {
          name = "${values.uniqueName}";
          app = name;
        };
        spec = {
          containers."tikv" = {
            image = "${values.tikv.image.repository}:${values.tikv.image.tag}";
            imagePullPolicy = values.tikv.image.pullPolicy;
            env = [
              {
                name = "HEADLESS_SERVICE_NAME";
                value = "${values.uniqueName}-peer";
              }
              {
                name = "NAMESPACE";
                valueFrom.fieldRef.fieldPath = "metadata.namespace";
              }
            ];
            ports."server".containerPort = values.tikv.service.port;
            command = [
              "/bin/sh"
              "-ecx"
              ''
                /tikv-server \
                  --addr="0.0.0.0:${builtins.toString values.tikv.service.port}" \
                  --advertise-addr="''${HOSTNAME}.''${HEADLESS_SERVICE_NAME}.''${NAMESPACE}.svc:${builtins.toString values.tikv.service.port}" \
                  --status-addr=0.0.0.0:${builtins.toString values.tikv.service.status_port} \
                  --advertise-status-addr="''${HOSTNAME}.''${HEADLESS_SERVICE_NAME}.''${NAMESPACE}.svc:${builtins.toString values.tikv.service.status_port}" \
                  --data-dir="/var/lib/tikv" \
                  --capacity=0 \
                  --config=/etc/tikv/tikv.toml \
                  --pd="http://${values.uniqueName}-pd:${builtins.toString values.pd.service.port}"
              ''
            ];
            volumeMounts = {
              "data" = {
                name = "${values.uniqueName}-data";
                mountPath = "/var/lib/tikv";
              };
              "config" = {
                name = "config";
                mountPath = "/etc/tikv";
                readOnly = true;
              };
            };
            # TODO: liveness and readiness probes
          };
          volumes."config".configMap = {
            defaultMode = 420;
            items = [
              {
                key = "tikv.toml";
                path = "tikv.toml";
              }
            ];
            name = "${values.uniqueName}-config";
          };
        };
      };
      volumeClaimTemplates = [
        {
          metadata.name = "${values.uniqueName}-data";
          spec = {
            accessModes = ["ReadWriteOnce"];
            resources.requests.storage = values.tikv.storage;
          };
        }
      ];
    };
  };
}
