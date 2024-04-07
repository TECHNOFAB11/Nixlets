{
  lib,
  utils,
  project,
  ...
}:
with lib; {
  # for some basic values see https://github.com/helm/examples/blob/4888ba8fb8180dd0c36d1e84c1fcafc6efd81532/charts/hello-world/values.yaml
  options = {
    pd = utils.mkNestedOption {
      replicaCount = mkOption {
        type = types.int;
        default = 3;
      };
      image = utils.mkNestedOption {
        repository = mkOption {
          type = types.str;
          default = "pingcap/pd";
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
      service = utils.mkNestedOption {
        peer_port = mkOption {
          type = types.int;
          default = 2380;
        };
        client_port = mkOption {
          type = types.int;
          default = 2379;
        };
        type = mkOption {
          type = types.str;
          default = "ClusterIP";
        };
      };
    };
    tikv = utils.mkNestedOption {
      replicaCount = mkOption {
        type = types.int;
        default = 3;
      };
      image = utils.mkNestedOption {
        repository = mkOption {
          type = types.str;
          default = "pingcap/tikv";
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
      service = utils.mkNestedOption {
        client_port = mkOption {
          type = types.int;
          default = 20160;
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
    };

    # internal
    uniqueName = mkOption {
      internal = true;
      type = types.str;
      default = "${project}-tikv";
    };
  };
}
