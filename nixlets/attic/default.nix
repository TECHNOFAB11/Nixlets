{...}: {
  imports = [
    ./deployment.nix
    ./configMap.nix
    ./service.nix
    ./persistentVolumeClaim.nix
  ];
}
