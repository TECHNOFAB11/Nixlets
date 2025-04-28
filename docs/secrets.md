# Secrets

When using Nixlets together with tools like [FluxCD](https://fluxcd.io) and
[SOPS](https://github.com/getsops/sops) it makes sense to apply the secrets on
their own (eg. with their own FluxCD's `Kustomization`).

To make secret management easier, Nixlets allow you to specify encrypted secret
files in your configuration like this:

```nix title="some_resource.nix"
  # ...
  kubernetes.secrets."name" = ./secret.sops.yaml;
  kubernetes.resources.configMaps. # ...
  # ...
```

In CI for example you can then retrieve all of these files at once and put them
in an OCI image for FluxCD to deploy:

```nix title="flake.nix"
packages.secrets = (<some nixlet>).secretsCombined; # (derivation)
```

```sh
nix build .#secrets
# result/ contains all yaml secret files
```
