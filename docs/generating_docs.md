# Generating Docs

Like you can see on the left (if you are looking at the built MkDocs site), it's possible
to generate docs for Nixlets' values automatically.
Since the values are basically just Nix module options, we can generate docs similarly to NixOS options etc.

## Generate Markdown

This is all that's needed:

```nix
(<nixlet>).mkDocs {
# Params:
#  transformOptions ? opt: opt,
#  filter ? _: true,
#  headingDepth ? 3,
}
```

This will return the path to a markdown file containing the docs, like this:

````md
### `example`

(no description)

**Type**:

```console
string
```

**Default value**:

```nix
"Hello world!"
```
````
