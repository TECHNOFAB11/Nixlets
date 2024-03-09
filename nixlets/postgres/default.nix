{...}: {
  imports = [
    ./statefulSet.nix
    ./service.nix
    ./persistentVolumeClaim.nix
  ];
}
