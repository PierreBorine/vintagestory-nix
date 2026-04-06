{packages}: rec {
  vs-launcher = import ./vs-launcher/hm.nix packages;
  mvl = import ./mvl/hm.nix packages;

  default = {
    imports = [vs-launcher mvl];
  };
}
