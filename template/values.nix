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
    # define values here
  };
}
