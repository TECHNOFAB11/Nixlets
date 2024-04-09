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
          default = "v7.1.0";
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
        port = mkOption {
          type = types.int;
          default = 2379;
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
          default = "v7.1.0";
        };
        pullPolicy = mkOption {
          type = types.str;
          default = "IfNotPresent";
        };
      };
      service = utils.mkNestedOption {
        port = mkOption {
          type = types.int;
          default = 20160;
        };
        status_port = mkOption {
          type = types.int;
          default = 20180;
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
      config = mkOption {
        type = types.attrs;
        default = {
          raftdb.max-open-files = 256;
          rocksdb.max-open-files = 256;
          storage.reserve-space = "0MB";
        };
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
