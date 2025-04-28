# Creating Nixlets

Nixlets need a `default.nix` and a `values.nix` (a `nixlet.nix` containing the metadata is also recommended).

Check out the existing [nixlets](https://gitlab.com/technofab/nixlets/-/tree/main/nixlets) to understand how they work.
There is also a bare-bones [template](https://gitlab.com/technofab/nixlets/-/tree/main/template/).

## `nixlet.nix`

```nix title="Example"
{
  name = "attic";
  version = "0.0.1";
  description = "Multi-tenant Nix Binary Cache";
  defaultProject = "attic";
}
```

<!-- TODO: more description, also show how it works without this file -->

It's best to create a file `nixlet.nix` for your Nixlet. It's possible to create
Nixlets without this file, by passing the metadata directly to `mkNixlet`, but
when you intend to package the Nixlet this won't work, because when fetching
Nixlets it expects the metadata.

```nix title="Usage without nixlet.nix"
mkNixlet {
  name = "";
  version = "";
  # etc.
}
```

```nix title="Usage with nixlet.nix"
mkNixlet ./path;
```

Metadata:

- `name`: Name of the Nixlet
- `version`: Version of the Nixlet itself (like Helm Chart version)
- `description`: Short description of the Nixlet
- `defaultProject`: Kubenix has the concept of projects.
    This makes it possible to use the same Nixlet multiple times by specifying
    different projects. This is typically included in the resources' names.
    (see also `uniqueName` below)

## `values.nix`

```nix title="Template"
{
  lib,
  utils,
  nixlet,
  ...
}:
with lib;
with utils;
with nixlet; {
  # for some basic values see https://github.com/helm/examples/blob/4888ba8fb8180dd0c36d1e84c1fcafc6efd81532/charts/hello-world/values.yaml
  options = {
    # define values here
  };
}
```

In `values.nix` you declare options the end-user can set.
This uses the NixOS/nixpkgs module system.

To create a simple string input you can add this in the `options = {}` above:

```nix title="Simple string value"
hello = mkOption {
  type = types.str;
  default = "World";
  description = "Hello world!";
}
```

The end-user using your Nixlet can then do this:

```nix title="Usage"
nixlet.render {
  # ...
  values = {
    hello = "Nixlets";
  };
}
```

It is recommended to use an option like seen below to create a unique name for the Nixlet's resources.

```nix
# internal
uniqueName = mkOption {
  internal = true;
  type = types.str;
  default = "${project}-atticd";  # example for atticd
};
```

Then use that in your resource names like seen below.

## `default.nix`

This file is the entrypoint to your Nixlet. You can define all the resources
in this file directly or import other files.

```nix
{nixlet, ...}:
with nixlet; {
  imports = [./some-resource.nix];
  # or directly
  kubernetes.resources.configMaps."${values.uniqueName}-config".data.hello = values.hello;
}
```
