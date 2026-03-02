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
      "v${v}" = builders.mkVintageStoryV2 {inherit version hash;};
      "v${v}-net8" = builtins.warn ''
        'v${v}-net8' is deprecated, please use 'v${v}' instead. As of 1.21, Vintage Story officially uses dotnet8.
      '' attrs."v${v}";
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

    # {v-1-20 = <der>;}
    latestVersion = {
      "v${majorMinor}" = highestVersionSet."v${highestVersion}";
      "v${majorMinor}-net8" = builtins.warn ''
        'v${majorMinor}-net8' is deprecated, please use 'v${majorMinor}' instead. As of 1.21, Vintage Story officially uses dotnet8.
      '' latestVersion."v${majorMinor}";
    };
  in
    clib.recursiveMergeAttrsList ([latestVersion] ++ versions');

  importMinorVersion = f: mkMinorVersion (import f);
in {
  inherit mkMinorVersion importMinorVersion;
}
