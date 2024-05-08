{lib, ...}:
with lib; {
  mkNestedOption = options:
    mkOption {
      type = types.submodule {
        inherit options;
      };
      default = {};
    };
}
