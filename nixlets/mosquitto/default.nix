{...}: {
  imports = [
    ./statefulSet.nix
    ./service.nix
    ./configMap.nix
    ./persistentVolumeClaim.nix
  ];
}
