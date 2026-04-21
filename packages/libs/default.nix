{lib}: let
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

  mkPackageSet = packages: let
    latest-minor = majorMinorNormalized (highestVersion packages);
    packages-set = recursiveMergeAttrsList packages;
  in
    packages-set
    // {
      latest = packages-set."v${latest-minor}";
    };
in {
  inherit
    recursiveMergeAttrsList
    majorMinorNormalized
    normalizeVersion
    highestVersion
    filterUnstable
    mkPackageSet
    ;
}
