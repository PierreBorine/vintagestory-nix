pkgs: {
  mvl = pkgs.callPackage ./mvl/default.nix {};
  rustique = pkgs.callPackage ./rustique {};
  vs-launcher = pkgs.callPackage ./vs-launcher {};
  vsmodelcreator = pkgs.callPackage ./vsmodelcreator {};
}
