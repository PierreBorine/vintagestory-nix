{clib}: let
  importMinorVersion = builder: f: let
    mkVSVersion = {
      version,
      hash,
    }: let
      v = clib.normalizeVersion version;
      attrs = {
        "v${v}" = builder {inherit version hash;};
        # TODO: remove .NET8 hack when 1.22 hits unstable
        "v${v}-net8" = builtins.warn ''
          'v${v}-net8' is deprecated, please use 'v${v}' instead. As of 1.21, Vintage Story officially uses dotnet8.
        '' attrs."v${v}";
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
          "v${majorMinor}-net8" = builtins.warn ''
            'v${majorMinor}-net8' is deprecated, please use 'v${majorMinor}' instead. As of 1.21, Vintage Story officially uses dotnet8.
          '' latestVersion."v${majorMinor}";
        };
    in
      clib.recursiveMergeAttrsList ([latestVersion] ++ versions');
  in mkMinorVersion (import f);
in
  importMinorVersion
