{
  inputs,
  lib,
  ...
} @ attrs:
with lib; {
  mkValues = file: {rawValues, ...} @ args:
    (lib.evalModules {
      specialArgs = {
        utils = import ./. attrs;
      };
      modules = [
        file
        ({...}: {
          # pass through all args to the values.nix module
          config =
            rawValues
            // {
              _module.args = args;
            };
        })
      ];
    })
    .config;

  mkNestedOption = options:
    mkOption {
      type = types.submodule {
        inherit options;
      };
      default = {};
    };

  mkNixlet = path: let
    utils = import ./. attrs;
  in
    {
      rawValues,
      project,
      ...
    } @ args: {
      kubenix,
      lib,
      ...
    } @ attrs: let
      values = utils.mkValues "${path}/values.nix" args;
    in {
      imports = [path];
      # make values accessible from every imported file
      _module.args = {inherit values;};
    };

  renderNixlet = {
    system,
    project,
    nixlet,
    values ? {},
    overrides ? {...}: {},
  }:
    (inputs.kubenix.evalModules.${system} {
      module = {kubenix, ...}: {
        imports = with kubenix.modules; [
          k8s
          helm
          docker
          files
          (nixlet {
            # all these args are available in values.nix
            inherit project;
            rawValues = values;
          })
          overrides
        ];
        kubenix.project = project;
      };
    })
    .config
    .kubernetes
    .resultYAML;
}
