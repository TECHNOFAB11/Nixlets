# Nixlets

This repository contains utilities for creating Nixlets and a collection of Nixlets. \
Nixlets are kinda like Helm Charts, but they are defined using Kubenix and the Nix language. \
\
One can load Nixlets either via Nix Flakes or by fetching a tarball


## Usage

### Creating Nixlets
Nixlets need a `default.nix` and a `values.nix` (a `nixlet.nix` containing the metadata is also recommended). \
Check out the existing [nixlets](./nixlets/) to understand how they work. \
There is also a bare-bones [template](./template/).

### Using/rendering Nixlets
To render nixlets you only need to import the nixlets-lib:
```nix
{
  inputs.nixlet-lib.url = "gitlab:TECHNOFAB/nixlets?dir=lib";
}
```

#### Nixlets stored in the Gitlab Package Registry
```nix
(nixlet-lib.fetchNixletFromGitlab {
  project = "TECHNOFAB/nixlets";
  name = "<nixlet>";
  version = "<version>";
  sha256 = "<sha>";
}).render {
  inherit system;
  # values = {};
  # project = "";
  # overrides = ({...}: {});
}
```

#### Nixlets fetchable from arbitrary URLs
```nix
(nixlet-lib.fetchNixlet "<URL>" "<sha>").render {
  # ...
}
```

#### Metadata
Metadata of the Nixlets can also easily be accessed if needed:
```nix
(<some nixlet>).description # version, name, etc.
```
