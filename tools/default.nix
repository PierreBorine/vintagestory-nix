pkgs: {
  mvl = pkgs.callPackage ./mvl {};
  rustique = pkgs.callPackage ./rustique {};
  vs-launcher =
    builtins.warn ''
      vintagestory-nix: vs-launcher's repository was archived on June 27, 2026
      and is officially abandoned. The officially recommended alternative is MVL.
      More info at https://mods.vintagestory.at/show/mod/16326.
    ''
    pkgs.callPackage
    ./vs-launcher {};
  vsmodelcreator = pkgs.callPackage ./vsmodelcreator {};
}
