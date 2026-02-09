# Importing Nixlets

Nixlets can now define dependency Nixlets and handle them similarly to how nested
Helm Charts work.

## Importing

To define a dependency Nixlet, give it a name and pass the Nixlet as a value:

```nix title="default.nix of Nixlet"
  nixlet.dependencies."postgres" = <any nixlet>;
```

`<any nixlet>` here could be stuff like `nixlet-lib.fetchNixletFromGitlab {...}`,
`nixlet-lib.fetchNixlet <url> <sha>`, etc.

## Defining Values

You can pre-define values for dependency Nixlets like this:

```nix title="values.nix of Nixlet"
  options = {
    # options for the current Nixlet
  };
  # overwriting the default of dependency Nixlets (the user can still overwrite this)
  config."postgres".replicaCount = 10;
```

