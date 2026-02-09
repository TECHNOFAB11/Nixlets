{
  lib,
  nixlet,
  # whether to generate docs for the full values, including dependencies
  fullValues ? false,
  transformOptions ? opt: opt,
  filter ? _: true,
  headingDepth ? 3,
  ...
}: let
  inherit
    (lib)
    removeSuffix
    concatStringsSep
    mapAttrsToList
    concatStrings
    replicate
    optionalString
    optionAttrSetToDocList
    attrByPath
    generators
    ;
  inherit (generators) toPretty;

  _transformOptions = opt:
    transformOptions (opt
      // {
        visible = let
          filtered = !builtins.elem (builtins.head opt.loc) ["_module"];
        in
          filtered && opt.visible && (filter opt);
        name = lib.removePrefix "config." opt.name;
      });

  valueSource =
    if fullValues
    # TODO: get rid of system, just here cuz of kubenix
    then (nixlet.fullValues {system = "x86_64-linux";})
    else nixlet.values;
  rawOpts = optionAttrSetToDocList valueSource.options;
  transformedOpts = map _transformOptions rawOpts;
  filteredOpts = lib.filter (opt: opt.visible && !opt.internal) transformedOpts;

  optionsNix = builtins.listToAttrs (
    map (o: {
      inherit (o) name;
      value = removeAttrs o [
        "visible"
        "internal"
      ];
    })
    filteredOpts
  );

  optToMd = opt: let
    headingDecl = concatStrings (replicate headingDepth "#");
  in
    ''
      ${headingDecl} `${opt.name}`

      ${
        if opt.description != null
        then opt.description
        else "(no description)"
      }

      **Type**:

      ```console
      ${opt.type}
      ```
    ''
    # used to show what changes a nixlet did to values of dependencies
    + (let
      val = toPretty {} (attrByPath opt.loc "_not found_" valueSource.config);
      default = removeSuffix "\n" opt.default.text;
    in
      optionalString (opt.type != "submodule" && val != default)
      ''
        **Overridden value**:

        ```nix
        ${val}
        ```
      '')
    + (optionalString (opt ? default && opt.default != null) ''

      **Default value**:

      ```nix
      ${removeSuffix "\n" opt.default.text}
      ```
    '')
    + (optionalString (opt ? example) ''

      **Example value**:

      ```nix
      ${removeSuffix "\n" opt.example.text}
      ```
    '')
    + "\n";

  opts =
    mapAttrsToList (_name: optToMd)
    optionsNix;
  markdown = concatStringsSep "\n" opts;
in
  builtins.toFile "values-doc.md" markdown
