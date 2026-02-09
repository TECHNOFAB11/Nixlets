{
  lib,
  config,
  nixlet,
  system,
  ...
}: let
  inherit (lib) mkOption types mkOptionType isType mkMerge mapAttrs mkIf literalExpression;
  cfg = config.nixlet;

  nixletType = mkOptionType {
    name = "nixlet";
    description = "reference";
    descriptionClass = "noun";
    check = isType "nixlet";
  };
in {
  imports = [
    {
      # shortcut, allows accessing deps a bit shorter/more easily
      _module.args.deps = cfg.deps;
    }
  ];
  options.nixlet = {
    dependencies = mkOption {
      type = types.attrsOf nixletType;
      default = {};
      description = ''
        Import other nixlets as dependencies. Works similar to Helm, specify values for these
        Nixlets by using their name as a prefix. Like `postgres.replicaCount` in `values.nix` for example.
      '';
      example = literalExpression ''
        {
          "postgres" = nixlet-lib.mkNixlet <path>;
          "mongodb" = nixlet-lib.fetchNixlet ...; # etc.
        }
      '';
    };
    deps = mkOption {
      readOnly = true;
      type = types.attrsOf types.attrs;
      default = mapAttrs (name: val:
        builtins.addErrorContext "[nixlets] while evaluating dependency ${name}"
        (val.eval {
          inherit system;
          inherit (config.kubenix) project;
          values = nixlet.values.${name};
        }).config)
      cfg.dependencies;
      description = ''
        Evaluated dependency nixlets. Allows accessing their resources like for example:

        ```nix
        config.nixlet.deps."<name>".kubernetes.resources
        ```
      '';
    };
    depAutoMerge = mkOption {
      type = types.bool;
      default = true;
      description = ''
        Whether to automatically merge dependency nixlets' configs
        with the current nixlet. If disabled, you can access dependency outputs via:

        ```nix
        config.nixlet.deps."<name>".kubernetes.resources
        ```
      '';
    };
  };

  config = mkIf cfg.depAutoMerge {
    kubernetes.resources = mkMerge (map (dep: dep.kubernetes.resources) (builtins.attrValues cfg.deps));
  };
}
