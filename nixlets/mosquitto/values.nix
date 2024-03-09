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
        default = "eclipse-mosquitto";
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
      port = mkOption {
        type = types.int;
        default = 1883;
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
    passwordAuthEnabled = mkOption {
      type = types.bool;
      default = true;
    };
    configContent = mkOption {
      type = types.str;
      default = ''
        listener 1883
        persistence true
        persistence_location /mosquitto/data
        autosave_interval 1800
        password_file /mosquitto/config/password_file
      '';
    };

    # internal
    uniqueName = mkOption {
      internal = true;
      type = types.str;
      default = "${project}-mosquitto";
    };
  };
}
