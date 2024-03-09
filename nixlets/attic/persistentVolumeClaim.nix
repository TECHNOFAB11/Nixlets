{
  values,
  lib,
  ...
}: {
  kubernetes.resources = {
    persistentVolumeClaims."${values.uniqueName}-data".spec = lib.mkIf (!values.externalStorage) {
      accessModes = ["ReadWriteOnce"];
      resources.requests.storage = values.storage;
    };
  };
}
