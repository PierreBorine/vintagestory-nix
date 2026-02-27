{
  builders,
  clib,
  lib,
}: let
  mkVSVersion = {
    version,
    hash,
  }: let
    v = clib.normalizeVersion version;
    attrs = {
      "v${v}" = builders.mkVintageStoryV1 {inherit version hash;};
      "v${v}-net8" = builders.mkDotnet8 attrs."v${v}";
    };
  in
    attrs;

  mkMinorVersion = versions: let
    versions' = map mkVSVersion versions;
    highestVersionSet = clib.highestVersion versions';

    # "1.20.4" => "1-20"
    majorMinor =
      clib.normalizeVersion (lib.versions.majorMinor highestVersionSet.version);
    highestVersion = clib.normalizeVersion highestVersionSet.version;

    # {v-1-20 = <der>; v1-20-net8 = <der>;}
    latestVersion = {
      "v${majorMinor}" = highestVersionSet."v${highestVersion}";
      "v${majorMinor}-net8" = highestVersionSet."v${highestVersion}-net8";
    };
  in
    clib.recursiveMergeAttrsList ([latestVersion] ++ versions');

  importMinorVersion = f: mkMinorVersion (import f);
in {
  inherit mkMinorVersion importMinorVersion;
}
