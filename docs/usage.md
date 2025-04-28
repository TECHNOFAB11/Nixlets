# Using Nixlets

## Fetching

You can fetch Nixlets you uploaded somewhere [earlier](./packaging.md) using an URL to the tarball and the sha256 hash:

```nix
nixlet-lib.fetchNixlet "<URL>" "<sha>"
```

For the GitLab Package Registry there is a helper function:

```nix
nixlet-lib.fetchNixletFromGitlab {
  project = "<org>/<project>"; # eg "TECHNOFAB/nixlets"
  name = "<nixlet>";
  version = "<version>";
  sha256 = "<sha>";
}
```

## Metadata

A Nixlet's metadata can easily be accessed:

```nix
(<some nixlet>).description # version, name, etc.
```

## Rendering

Rendering a Nixlet will produce a YAML file which contains all the resources.

```nix
(<some nixlet>).render {
  inherit system;
  # values = {};
  # project = "";
  # overrides = ({...}: {});
}
```

Parameters:

- `system`: needed for Kubenix to work.
- `values`: values to pass to the Nixlet, gets validated by the Nixlets options
- `project`: project to use, makes it possible to use the same Nixlet multiple
    times without conflicts
- `overrides`: custom module which can override configuration

## Just evaluating

Instead of directly rendering a Nixlet it's also possible to just evaluate it
and access all kinds of data inside it.

```nix
(<some nixlet>).eval {
  # see above
}
```

It accepts the same parameters as `render`.
