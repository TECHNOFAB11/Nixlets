{nixlet, ...}:
with nixlet; {
  kubernetes.resources = {
    statefulSets."${values.uniqueName}".spec = {
      replicas = values.replicaCount;
      selector.matchLabels.name = "${values.uniqueName}";
      serviceName = "${values.uniqueName}";
      template = {
        metadata.labels.name = "${values.uniqueName}";
        spec = {
          containers."mosquitto" = {
            image = "${values.image.repository}:${values.image.tag}";
            imagePullPolicy = values.image.pullPolicy;
            ports."mqtt".containerPort = 1883;
            volumeMounts = {
              "password-file" = {
                name = "password-file";
                mountPath = "/mosquitto/config/password_file";
                subPath = "password_file";
              };
              "config" = {
                name = "config";
                mountPath = "/mosquitto/config/mosquitto.conf";
                subPath = "mosquitto.conf";
              };
              "data" = {
                name = "data";
                mountPath = "/mosquitto/data";
              };
            };
          };
          volumes = {
            "password-file".secret.secretName = "${values.uniqueName}";
            "config".configMap.name = "${values.uniqueName}-config";
            "data".persistentVolumeClaim.claimName = "${values.uniqueName}-data";
          };
        };
      };
    };
  };
}
