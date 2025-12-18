# Packaging Nixlets

## GitLab Package Registry

To package and upload Nixlets to the GitLab Package Registry there is a helper script available.
Use it like so:

```nix title="flake.nix"
apps.upload = {
  type = "app";
  program = pkgs.callPackage nixlet-lib.uploadNixletsToGitlab {
    projectId = "<GitLab Project ID>";
    nixlets = [
      # list of Nixlets
    ];
  };
};
```

You can then run this:

```sh
nix run .#upload --impure
```

`--impure` is needed because the Script needs to access the env variable `AUTH_HEADER`.

`AUTH_HEADER` needs to contain the Header GitLab expects for auth.
In GitLab CI this should for example be `JOB-TOKEN: $CI_JOB_TOKEN`.
A personal access token requires this format instead: `PRIVATE-TOKEN: <your token>`.

!!! note

    The script only uploads a version once. If the version already exists it will skip that Nixlet.

## General

Nixlets are self contained and receive all their dependencies etc. from the
caller rendering it.

This means that you can just compress any Nixlet directory to a tarball, upload
it somewhere and then fetch it later where you intend to use/render it
(the upload script for GitLab CI does basically that).

See [Usage](./usage.md) for information on how to fetch and render it later.
