{
  values,
  lib,
  ...
}: {
  kubernetes.resources = let
    # switch to a StatefulSet if we don't use an external storage configuration
    type =
      if values.externalStorage
      then "deployments"
      else "statefulSets";
  in {
    ${type}."${values.uniqueName}" = {
      spec = {
        replicas = values.replicaCount;
        selector.matchLabels.app = "${values.uniqueName}";
        serviceName = "attic";
        template = {
          metadata.labels.app = "${values.uniqueName}";
          spec = {
            securityContext = {
              fsGroup = 1000;
              runAsUser = 1000;
              runAsGroup = 1000;
            };
            containers."api-server" = {
              image = "${values.image.repository}:${values.image.tag}";
              imagePullPolicy = values.image.pullPolicy;
              command = ["atticd" "-f" "/etc/attic/config.toml" "--mode" "monolithic"]; # TODO: only api-server can be replicated
              envFrom = [
                {secretRef.name = "${values.uniqueName}-env";}
              ];
              volumeMounts = {
                "config" = {
                  name = "config";
                  mountPath = "/etc/attic";
                  readOnly = true;
                };
                "data" = lib.mkIf (!values.externalStorage) {
                  name = "data";
                  mountPath = "/data";
                };
              };
            };
            volumes = {
              "config".configMap = {
                name = "${values.uniqueName}-config";
                items = [
                  {
                    key = "config.toml";
                    path = "config.toml";
                  }
                ];
              };
              "data".persistentVolumeClaim.claimName = lib.mkIf (!values.externalStorage) "${values.uniqueName}-data";
            };
          };
        };
      };
    };
  };
}
