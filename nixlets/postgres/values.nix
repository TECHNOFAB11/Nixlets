{
  lib,
  utils,
  nixlet,
  ...
}:
with lib;
with utils;
with nixlet; {
  # for some basic values see https://github.com/helm/examples/blob/4888ba8fb8180dd0c36d1e84c1fcafc6efd81532/charts/hello-world/values.yaml
  options = {
    replicaCount = mkOption {
      type = types.int;
      default = 1;
    };
    image = mkNestedOption {
      repository = mkOption {
        type = types.str;
        default = "postgres";
      };
      tag = mkOption {
        type = types.str;
        default = "latest";
      };
      pullPolicy = mkOption {
        type = types.str;
        default = "IfNotPresent";
      };
    };
    service = mkNestedOption {
      port = mkOption {
        type = types.int;
        default = 5432;
      };
      type = mkOption {
        type = types.str;
        default = "ClusterIP";
      };
    };
    storage = mkOption {
      type = types.str;
      default = "5G";
    };

    # internal
    uniqueName = mkOption {
      internal = true;
      type = types.str;
      default = "${project}-postgres";
    };
  };
}
