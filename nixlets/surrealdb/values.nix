{
  lib,
  utils,
  project,
  ...
}:
with lib; {
  # for some basic values see https://github.com/helm/examples/blob/4888ba8fb8180dd0c36d1e84c1fcafc6efd81532/charts/hello-world/values.yaml
  options = {
    replicaCount = mkOption {
      type = types.int;
      default = 1;
    };
    image = utils.mkNestedOption {
      repository = mkOption {
        type = types.str;
        default = "surrealdb/surrealdb";
      };
      pullPolicy = mkOption {
        type = types.str;
        default = "IfNotPresent";
      };
      tag = mkOption {
        type = types.str;
        default = "latest";
      };
    };
    service = utils.mkNestedOption {
      port = mkOption {
        type = types.int;
        default = 8000;
      };
      type = mkOption {
        type = types.str;
        default = "ClusterIP";
      };
    };
    surrealdb = utils.mkNestedOption {
      log = mkOption {
        type = types.str;
        default = "info";
      };
      path = mkOption {
        type = types.str;
        default = "memory";
        description = ''
          Path to database.
          Examples: "memory", "file://<path>", "tikv://<tikv-pd-service>:2379"
        '';
      };
    };

    # internal
    uniqueName = mkOption {
      internal = true;
      type = types.str;
      default = "${project}-surrealdb";
    };
  };
}
