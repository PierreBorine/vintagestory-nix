{
  builders,
  clib,
}: let
  importMinorVersion = f: let
    mkVSVersion = {
      version,
      hash,
    }: let
      v = clib.normalizeVersion version;
      attrs = {
        "v${v}" = builders.mkVintageStoryV1 {inherit version hash;};
      };
    in
      attrs;

    mkMinorVersion = versions: let
      versions' = map mkVSVersion versions;
      highestVersionSet = clib.highestVersion versions';

      majorMinor = clib.majorMinorNormalized highestVersionSet;
      highestVersion = clib.normalizeVersion highestVersionSet.version;

      # {v1-20 = <der>;}
      latestVersion =
        if (clib.filterUnstable versions') == []
        then {}
        else {
          "v${majorMinor}" = highestVersionSet."v${highestVersion}";
        };
    in
      clib.recursiveMergeAttrsList ([latestVersion] ++ versions');
  in
    mkMinorVersion (import f);
in
  importMinorVersion
