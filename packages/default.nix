{
  builders,
  lib,
}: let
  # "1.20.4" => "v1-20-4"
  normalizeVersion = v: "v" + (lib.replaceStrings ["."] ["-"] v);

  # {version = "1.20.4";} => "v1-20"
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

  # {v1-20-4 = <der>; v1-20-5 = <der>; v1-20 = <der>;}
  importMinorVersion = f: let
    mkMinorVersion = {
      builder,
      versions,
    }: let
      mkVSVersion = {
        version,
        hash,
      }: {
        ${normalizeVersion version} = builder {inherit version hash;};
      };

      versions' = map mkVSVersion versions;
      highestVersionSet = highestVersion versions';

      majorMinor = majorMinorNormalized highestVersionSet;
      highestVersion' = normalizeVersion highestVersionSet.version;

      # {v1-20 = <der>;}
      latestVersion = lib.optionalAttrs (filterUnstable versions' != []) {
        ${majorMinor} = highestVersionSet.${highestVersion'};
      };
    in
      lib.mergeAttrsList ([latestVersion] ++ versions');
  in
    mkMinorVersion (import f builders);

  mkPackageSet = packages': let
    packages = map importMinorVersion packages';
    # eg: "1-20", "1-21"
    latest-minor = majorMinorNormalized (highestVersion packages);
    packages-set = lib.mergeAttrsList packages;
  in
    packages-set
    // {
      latest = packages-set.${latest-minor};
    };

  # get all nix files in the directory (except default.nix)
  versions = lib.pipe ./. [
    lib.readDir
    (lib.filterAttrs (n: _: lib.hasSuffix ".nix" n && n != "default.nix"))
    (lib.mapAttrsToList (n: _: ./. + "/${n}"))
  ];
in
  mkPackageSet versions
