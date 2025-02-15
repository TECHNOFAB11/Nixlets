{
  description = "Use this as an input to access the nixlets. Override nixlet-lib to newer versions if needed.";

  outputs = import ./.;

  inputs = {
    nixlet-lib.url = "gitlab:technofab/nixlets?dir=lib";
  };
}
