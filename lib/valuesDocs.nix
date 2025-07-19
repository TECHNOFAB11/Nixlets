{
  lib,
  nixlet,
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
    ;

  _transformOptions = opt:
    transformOptions (opt
      // {
        visible = let
          filtered = !builtins.elem (builtins.head opt.loc) ["_module"];
        in
          filtered && opt.visible && (filter opt);
        name = lib.removePrefix "config." opt.name;
      });

  rawOpts = lib.optionAttrSetToDocList nixlet.values.options;
  transformedOpts = map _transformOptions rawOpts;
  filteredOpts = lib.filter (opt: opt.visible && !opt.internal) transformedOpts;

  optionsNix = builtins.listToAttrs (
    map (o: {
      name = o.name;
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
    + (lib.optionalString (opt ? default && opt.default != null) ''

      **Default value**:

      ```nix
      ${removeSuffix "\n" opt.default.text}
      ```
    '')
    + (lib.optionalString (opt ? example) ''

      **Example value**:

      ```nix
      ${removeSuffix "\n" opt.example.text}
      ```
    '')
    + "\n";

  opts = mapAttrsToList (name: opt:
    optToMd opt)
  optionsNix;
  markdown = concatStringsSep "\n" opts;
in
  builtins.toFile "values-doc.md" markdown
