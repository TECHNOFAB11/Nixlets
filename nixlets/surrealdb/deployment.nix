{
  nixlet,
  lib,
  ...
}:
with nixlet; {
  kubernetes.resources = {
    deployments."${values.uniqueName}" = {
      spec = {
        replicas = values.replicaCount;
        selector.matchLabels.app = "${values.uniqueName}";
        template = {
          metadata.labels.app = "${values.uniqueName}";
          spec = {
            securityContext = {
              fsGroup = 1000;
              runAsUser = 1000;
              runAsGroup = 1000;
            };
            containers."surrealdb" = rec {
              image = "${values.image.repository}:${values.image.tag}";
              imagePullPolicy = values.image.pullPolicy;
              args = ["start"];
              env = [
                {
                  name = "SURREAL_NO_BANNER";
                  value = "true";
                }
                {
                  name = "SURREAL_PATH";
                  value = values.surrealdb.path;
                }
                {
                  name = "SURREAL_LOG";
                  value = values.surrealdb.log;
                }
                {
                  name = "SURREAL_BIND";
                  value = "0.0.0.0:8000";
                }
              ];
              envFrom = [
                {secretRef.name = "${values.uniqueName}-env";}
              ];
              ports."http".containerPort = 8000;
              livenessProbe.httpGet = {
                path = "/health";
                port = "http";
              };
              readinessProbe = livenessProbe;
            };
          };
        };
      };
    };
  };
}
