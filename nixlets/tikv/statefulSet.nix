{values, ...}: {
  kubernetes.resources = {
    statefulSets."${values.uniqueName}-pd".spec = {
      replicas = values.pd.replicaCount;
      selector.matchLabels.name = "${values.uniqueName}-pd";
      serviceName = "${values.uniqueName}-pd";
      updateStrategy.type = "RollingUpdate";
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
                name = "INITIAL_CLUSTER_SIZE";
                value = "${builtins.toString values.pd.replicaCount}";
              }
              {
                name = "SET_NAME";
                value = "${values.uniqueName}-pd";
              }
              {
                name = "MY_POD_IP";
                valueFrom.fieldRef.fieldPath = "status.podIP";
              }
            ];
            ports = {
              "pd-server".containerPort = values.pd.service.client_port;
              "peer".containerPort = values.pd.service.peer_port;
            };
            command = [
              "/bin/sh"
              "-ec"
              ''
                HOSTNAME=$(hostname)
                PEERS=""

                for i in $(seq 0 $((''${INITIAL_CLUSTER_SIZE} - 1))); do
                  PEERS="''${PEERS}''${PEERS:+,}''${SET_NAME}-''${i}=http://''${SET_NAME}-''${i}.''${SET_NAME}:${builtins.toString values.pd.service.peer_port}"
                done

                /pd-server --name=''${HOSTNAME} \
                  --client-urls=http://0.0.0.0:${builtins.toString values.pd.service.client_port} \
                  --peer-urls=http://0.0.0.0:${builtins.toString values.pd.service.peer_port} \
                  --advertise-client-urls=http://$(MY_POD_IP):${builtins.toString values.pd.service.client_port} \
                  --advertise-peer-urls=http://''${HOSTNAME}.''${SET_NAME}:${builtins.toString values.pd.service.peer_port} \
                  --initial-cluster ''${PEERS}
              ''
            ];
          };
        };
      };
    };

    statefulSets."${values.uniqueName}".spec = {
      replicas = values.tikv.replicaCount;
      selector.matchLabels.name = "${values.uniqueName}";
      serviceName = "${values.uniqueName}";
      updateStrategy.type = "RollingUpdate";
      template = {
        metadata.labels.name = "${values.uniqueName}";
        spec = {
          initContainers."check-pd-port" = {
            image = "busybox";
            command = ["sh" "-c" "echo STATUS nc -w 1 ${values.uniqueName}-pd:${builtins.toString values.pd.service.client_port}"];
          };
          containers."tikv" = {
            image = "${values.tikv.image.repository}:${values.tikv.image.tag}";
            imagePullPolicy = values.tikv.image.pullPolicy;
            env = [
              {
                name = "MY_POD_IP";
                valueFrom.fieldRef.fieldPath = "status.podIP";
              }
            ];
            ports."client".containerPort = values.tikv.service.client_port;
            command = [
              "/bin/sh"
              "-ecx"
              ''
                /tikv-server \
                  --addr="0.0.0.0:${builtins.toString values.tikv.service.client_port}" \
                  --advertise-addr="$(MY_POD_IP):${builtins.toString values.tikv.service.client_port}" \
                  --data-dir="/data/tikv" \
                  --pd="${values.uniqueName}-pd:${builtins.toString values.pd.service.client_port}"
              ''
            ];
            volumeMounts."data" = {
              name = "${values.uniqueName}-data";
              mountPath = "/data";
            };
            # TODO: liveness and readiness probes
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
