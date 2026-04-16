{nixlet-lib, ...}: {
  config.nixlet.dependencies."example" = nixlet-lib.mkNixlet ../example;
}
