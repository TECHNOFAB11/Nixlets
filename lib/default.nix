{
  lib,
  kubenix,
  ...
} @ attrs:
with lib; rec {
  mkValues = file: {rawValues, ...} @ args:
    (lib.evalModules {
      specialArgs = {
        utils = import ./utils.nix attrs;
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

  # wraps mkNixletInner to allow passing either a path or an attrset
  mkNixlet = arg:
    mkNixletInner (
      if (builtins.typeOf arg) == "set"
      then arg
      else
        {path = arg;}
        // (
          if builtins.pathExists "${arg}/nixlet.nix"
          then (import "${arg}/nixlet.nix")
          else throw "Nixlet at '${arg}' does not contain nixlet.nix and mkNixlet was called with just a path"
        )
    );

  mkNixletInner = {
    path,
    name,
    version ? null,
    description ? "",
    defaultProject ? null,
    ...
  }: let
    # TODO: just like with the values check the args here with the options system?
  in {
    inherit name version description path;
    render = {
      system,
      project ? defaultProject,
      overrides ? ({...}: {}),
      values ? {},
    }:
      assert lib.assertMsg (project != null) "No default project set, please pass a project to the render method"; let
        # every nixlet gets "nixlet" as arg with some useful data about itself
        nixletArg = {
          inherit name project version description;
        };
      in
        (kubenix.evalModules.${system} {
          module = {kubenix, ...}: {
            imports = with kubenix.modules; [
              k8s
              helm
              docker
              files
              ({...}: let
                finalValues = mkValues "${path}/values.nix" {
                  rawValues = values;
                  nixlet = nixletArg;
                };
              in {
                imports = [path];
                _module.args.nixlet =
                  {
                    values = finalValues;
                  }
                  // nixletArg;
              })
              overrides
            ];
            kubenix.project = project;
          };
        })
        .config
        .kubernetes
        .resultYAML;
  };

  fetchNixlet = url: sha256: mkNixlet (builtins.fetchTarball {inherit url sha256;});
  fetchNixletFromGitlab = {
    project,
    name,
    version,
    sha256,
  }: let
    projectEscaped = builtins.replaceStrings ["/"] ["%2F"] project;
  in
    fetchNixlet "https://gitlab.com/api/v4/projects/${projectEscaped}/packages/generic/${name}/${version}/${name}.tar.gz" sha256;

  uploadNixletsToGitlab = {
    pkgs,
    projectId,
    nixlets,
    ...
  }:
    pkgs.writeShellScriptBin "nixlets-upload" (
      ''
        if [[ -z "$AUTH_HEADER" ]]; then
          echo "Must provide AUTH_HEADER environment variable!" 1>&2
          exit 1
        fi
      ''
      + lib.concatStringsSep "\n" (
        builtins.map (nixlet:
          with nixlet; ''
            URL="https://gitlab.com/api/v4/projects/${projectId}/packages/generic/${name}/${version}/${name}.tar.gz"
            if ${pkgs.curl}/bin/curl --output /dev/null --silent --head --fail --header "$AUTH_HEADER" $URL; then
              echo "> Skipped ${name}@${version} because it already exists in the Package Registry"
            else
              echo "> Uploading new version ${name}@${version}"
              ${pkgs.gnutar}/bin/tar -czf /tmp/${name}.tar.gz --mode='u+rwX' -C ${path} --transform 's/^\./\/${name}/' .
              ${pkgs.curl}/bin/curl --header "$AUTH_HEADER" --upload-file "/tmp/${name}.tar.gz" "$URL"; echo;
              ${pkgs.coreutils}/bin/rm -f /tmp/${nixlet.name}.tar.gz
              echo "> Finished ${name}@${version}, see above"
            fi
          '')
        nixlets
      )
    );
}
