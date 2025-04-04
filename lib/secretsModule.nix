{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib) mkOption types;
in {
  options.kubernetes = {
    secrets = mkOption {
      type = types.attrsOf types.path;
      description = "sops encrypted secrets";
      example = ''
        {
          "abc" = ./some-secret.sops.yaml;
        }
      '';
    };
    secretsCombined = mkOption {
      internal = true;
      type = types.package;
      description = "All sops encrypted secret files in a directory";
    };
  };
  config.kubernetes.secretsCombined = let
    commands = builtins.concatStringsSep "\n" (
      map (
        secret: "ln -s ${builtins.getAttr secret config.kubernetes.secrets} $out/${secret}.yaml"
      )
      (builtins.attrNames config.kubernetes.secrets)
    );
  in
    pkgs.runCommand "nixlets-secrets-combined" {} ''
      mkdir -p $out
      ${commands}
    '';
}
