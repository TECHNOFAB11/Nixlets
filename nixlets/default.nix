{nixlet-lib, ...}:
# █▄ █ █ ▀▄▀ █   █▀▀ ▀█▀ █▀
# █ ▀█ █ █ █ █▄▄ ██▄  █  ▄█
with nixlet-lib; {
  mosquitto = mkNixlet ./mosquitto;
  attic = mkNixlet ./attic;
  postgres = mkNixlet ./postgres;
  tikv = mkNixlet ./tikv;
  surrealdb = mkNixlet ./surrealdb;
}
