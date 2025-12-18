{lib, ...}:
with lib; {
  options = {
    example = mkOption {
      type = types.str;
      default = "Hello world!";
      description = ''
        Some description.
      '';
    };
  };
}
