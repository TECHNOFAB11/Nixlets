# Nixlets

This repository contains utilities for creating Nixlets and a collection of Nixlets. \
Nixlets are kinda like Helm Charts but they are defined using Kubenix and the Nix language. \
\
One can import the Flake and use the renderNixlet function to turn values (like in Helm) into Kubernetes manifests in YAML.

## Examples
Check out the existing [nixlets](./nixlets/) to understand how they work. \
There is also a bare bones [template](./template/).
