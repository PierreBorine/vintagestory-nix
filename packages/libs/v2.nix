{clib}: let
  importMinorVersion = builder: f: let
    mkVSVersion = {
      version,
      hash,
    }: {
      "v${clib.normalizeVersion version}" = builder {inherit version hash;};
    };

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
