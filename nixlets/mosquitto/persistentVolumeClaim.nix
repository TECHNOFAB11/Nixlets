{values, ...}: {
  kubernetes.resources = {
    persistentVolumeClaims."${values.uniqueName}-data".spec = {
      accessModes = ["ReadWriteOnce"];
      resources.requests.storage = values.storage;
    };
  };
}
