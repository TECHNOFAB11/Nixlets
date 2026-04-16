{nixlet, ...}:
with nixlet; {
  kubernetes.resources.configMaps."test".data."test" = values.example;
}
