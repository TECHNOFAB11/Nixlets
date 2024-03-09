{values, ...}: {
  kubernetes.resources = {
    statefulSets."${values.uniqueName}".spec = {
      replicas = values.replicaCount;
      selector.matchLabels.name = "${values.uniqueName}";
      serviceName = "${values.uniqueName}";
      template = {
        metadata.labels.name = "${values.uniqueName}";
        spec = {
          containers."postgres" = {
            image = "${values.image.repository}:${values.image.tag}";
            imagePullPolicy = values.image.pullPolicy;
            ports."tcp".containerPort = 5432;
            volumeMounts."data" = {
              name = "data";
              mountPath = "/var/lib/postgresql/data";
            };
          };
          volumes = {
            "data".persistentVolumeClaim.claimName = "${values.uniqueName}-data";
          };
        };
      };
    };
  };
}
