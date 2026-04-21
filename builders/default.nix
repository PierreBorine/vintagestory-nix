pkgs: rec {
  # Wrapper function to easily package a new version of Vintage Story.
  #
  # mkVintageStory {version = "1.20.4"; hash = "sha256-Hgp2u/y2uPnJhAmPpwof76/woFGz4ISUXU+FIRMjMuQ=";}
  # => <Vintage Story derivation>
  # 1.18.8 -> 1.20.12
  mkVintageStoryV1 = pkgs.callPackage (import ./mk-vintagestory-v1.nix);
  # 1.21
  mkVintageStoryV2 = pkgs.callPackage (import ./mk-vintagestory-v2.nix);
  # 1.22 -> ...
  mkVintageStoryV3 = pkgs.callPackage (import ./mk-vintagestory-v3.nix);

  # Wrapper function that selects the correct derivation to use
  # based on the version
  mkVintageStory = arg: let
    inherit (pkgs.lib) versionOlder;
  in
    if versionOlder arg.version "1.18.8"
    then throw "Versions past 1.18.8 are not packagable using this flake."
    else if versionOlder arg.version "1.21"
    then mkVintageStoryV1 arg
    else if versionOlder arg.version "1.22"
    then mkVintageStoryV2 arg
    else mkVintageStoryV3 arg;
  # else throw "Versions past 1.10.12 are not (yet) packagable using this flake.";
}
