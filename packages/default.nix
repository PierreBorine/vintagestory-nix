{
  builders,
  lib,
}: let
  # common libs
  clib = import ./libs {inherit lib;};
  v1 = import ./libs/v1.nix {inherit clib;};
in
  clib.mkPackageSet [
    (v1 builders.mkVintageStoryV3 ./1-22.nix)
    (v1 builders.mkVintageStoryV2 ./1-21.nix)
    (v1 builders.mkVintageStoryV1 ./1-20.nix)
    (v1 builders.mkVintageStoryV1 ./1-19.nix)
    (v1 builders.mkVintageStoryV1 ./1-18.nix)
  ]
