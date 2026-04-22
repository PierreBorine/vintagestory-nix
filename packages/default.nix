{
  builders,
  lib,
}: let
  recursiveMergeAttrsList =
    lib.foldl' (acc: attr: lib.recursiveUpdate acc attr) {};

  # "1.20.4" => "1-20-4"
  normalizeVersion = lib.replaceStrings ["."] ["-"];

  # {version = "1.20.4";} => "1-20"
  majorMinorNormalized = package:
    normalizeVersion (lib.versions.majorMinor package.version);

  getVersion = set: (lib.head (lib.attrValues set)).version;

  isStable = version:
    (lib.intersectLists (lib.splitVersion version) ["pre" "rc"]) == [];
  filterUnstable = lib.filter (el: isStable (getVersion el));

  highestVersion = versions: let
    versions' = filterUnstable versions;
  in
    lib.foldl' (
      maxSet: set: let
        maxSetVersion = getVersion maxSet;
        setVersion = getVersion set;
      in
        if lib.versionOlder setVersion maxSetVersion
        then maxSet // {version = maxSetVersion;}
        else set // {version = setVersion;}
    ) (lib.head versions')
    versions';

  importMinorVersion = f: let
    mkMinorVersion = {
      builder,
      versions,
    }: let
      mkVSVersion = {
        version,
        hash,
      }: {
        "v${normalizeVersion version}" = builder {inherit version hash;};
      };

      versions' = map mkVSVersion versions;
      highestVersionSet = highestVersion versions';

      majorMinor = majorMinorNormalized highestVersionSet;
      highestVersion' = normalizeVersion highestVersionSet.version;

      # {v1-20 = <der>;}
      latestVersion =
        if (filterUnstable versions') == []
        then {}
        else {
          "v${majorMinor}" = highestVersionSet."v${highestVersion'}";
        };
    in
      recursiveMergeAttrsList ([latestVersion] ++ versions');
  in
    mkMinorVersion (import f builders);

  mkPackageSet = packages': let
    packages = map importMinorVersion packages';
    latest-minor = majorMinorNormalized (highestVersion packages);
    packages-set = recursiveMergeAttrsList packages;
  in
    packages-set
    // {
      latest = packages-set."v${latest-minor}";
    };

  versions = lib.pipe ./. [
    lib.readDir
    (lib.filterAttrs (n: _: lib.hasSuffix ".nix" n && n != "default.nix"))
    (lib.mapAttrsToList (n: _: ./. + "/${n}"))
  ];
in
  mkPackageSet versions
