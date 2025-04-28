# Nixlets

Nixlets are like Helm Charts, but instead created using [Nix](https://nixos.org).
They are based on [KubeNix](https://kubenix.org)
(this [fork](https://github.com/TECHNOFAB11/kubenix) specifically).

## Features

- supports importing Helm Charts, Kustomizations and YAML files if needed
- reproducible thanks to Nix
- versionable (eg. by uploading to GitLab Package Registry)
- utilities for secret management
