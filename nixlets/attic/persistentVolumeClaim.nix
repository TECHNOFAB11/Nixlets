{
  nixlet,
  lib,
  ...
}:
with nixlet; {
  kubernetes.resources = {
    persistentVolumeClaims."${values.uniqueName}-data".spec = lib.mkIf (!values.externalStorage) {
      accessModes = ["ReadWriteOnce"];
      resources.requests.storage = values.storage;
    };
  };
}
