{
  lib,
  kubenix,
  ...
} @ attrs: let
  inherit (lib) mkOption types evalModules concatMapStringsSep assertMsg;
  nixlet-lib = rec {
    nixletModule = ./nixletModule.nix;

    evalValues = file: {
      rawValues,
      dependencies,
      args,
      check ? true,
      ...
    }: let
      moduleArgs =
        args
        // {
          utils = import ./utils.nix attrs;
        };
      # get the values from the dependencies, then import them nested
      # (so you can set postgres.replicaCount in values.nix for example when adding "postgres" as dependency)
      extraModules = map (depName: {
        options.${depName} = mkOption {
          type = types.submodule {
            imports = ["${dependencies.${depName}.path}/values.nix"];
            _module.args =
              moduleArgs
              // {
                # make sure that dependencies see their own name and version etc.
                nixlet = {
                  inherit (dependencies.${depName}) name version description;
                  inherit (moduleArgs.nixlet) project;
                };
              };
          };
          default = {};
          description = let
            n = dependencies.${depName};
          in ''
            Imported Nixlet as a dependency:

            |Name|Version|Description|
            |----|-------|-----------|
            |${n.name}|${n.version}|${n.description}|
          '';
        };
      }) (builtins.attrNames dependencies);
    in
      builtins.addErrorContext "[nixlets] while evaluating values" (
        evalModules {
          modules =
            [
              file
              {
                _module = {
                  args = moduleArgs;
                  inherit check;
                };
              }
              {config = rawValues;}
            ]
            ++ extraModules;
        }
      );

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
      # every nixlet gets "nixlet" as arg with some useful data about itself
      baseNixletArg = {
        inherit name version description;
        project = defaultProject;
      };
      nixlet = {
        _type = "nixlet";
        inherit name version description path;
        # just values of the current nixlet (lighweight)
        values = evalValues "${path}/values.nix" {
          rawValues = {};
          dependencies = {};
          # no checking since this doesn't include dependencies
          check = false;
          args.nixlet = baseNixletArg;
        };
        # full values, including dependencies etc. (complex)
        fullValues = args: let
          evaled = nixlet.eval args;
        in
          evalValues "${path}/values.nix" {
            rawValues = {};
            inherit (evaled.config.nixlet) dependencies;
            args.nixlet = baseNixletArg;
          };
        mkDocs = opts: mkDocs (opts // {inherit nixlet;});
        eval = {
          system,
          project ? defaultProject,
          overrides ? (_: {}),
          values ? {},
        }:
          assert assertMsg (project != null) "No default project set, please pass a project to the eval/render method"; let
            nixletArg = baseNixletArg // {inherit project;};
          in
            builtins.addErrorContext "[nixlets] while evaluating nixlet ${name}" (
              kubenix.evalModules.${system} {
                module = {
                  config,
                  kubenix,
                  ...
                }: {
                  imports = with kubenix.modules; [
                    k8s
                    helm
                    docker
                    files
                    ./secretsModule.nix
                    ./nixletModule.nix
                    (let
                      finalValues =
                        (evalValues "${path}/values.nix" {
                          rawValues = values;
                          inherit (config.nixlet) dependencies;
                          args.nixlet = nixletArg;
                        }).config;
                    in {
                      imports = [path];
                      _module.args = {
                        nixlet =
                          {
                            values = finalValues;
                          }
                          // nixletArg;
                        inherit nixlet-lib system;
                      };
                    })
                    overrides
                  ];
                  kubenix.project = project;
                };
              }
            );
        render = {
          system,
          project ? defaultProject,
          overrides ? (_: {}),
          values ? {},
        }:
          (nixlet.eval {
            inherit system project overrides values;
          })
          .config
          .kubernetes
          .resultYAML;
        # combines all secrets files in a single directory
        secrets = args: (nixlet.eval args).config.kubernetes.secretsCombined;

      };
    in
      nixlet;

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
        + concatMapStringsSep "\n" (
          (nixlet:
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

    mkDocs = opts:
      import ./valuesDocs.nix (opts // {inherit lib;});
  };
in
  nixlet-lib
