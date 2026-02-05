{
  builders,
  lib,
}: let
  # common libs
  clib = import ./libs {inherit lib;};
  v1 = import ./libs/v1.nix {inherit builders clib lib;};
  v2 = import ./libs/v2.nix {inherit clib lib;};
in
  clib.mkPackageSet [
    (v2 builders.mkVintageStoryV2 ./1-21.nix)
    (v1 ./1-20.nix)
    (v1 ./1-19.nix)
    (v1 ./1-18.nix)
  ]
