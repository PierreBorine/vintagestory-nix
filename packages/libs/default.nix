{lib}: let
  inherit
    (builtins)
    foldl'
    replaceStrings
    head
    attrValues
    filter
    splitVersion
    ;
  inherit (lib.attrsets) recursiveUpdate;
  inherit (lib.versions) majorMinor;
  inherit (lib.strings) versionOlder;
  inherit (lib.lists) intersectLists;

  recursiveMergeAttrsList =
    foldl' (acc: attr: recursiveUpdate acc attr) {};

  # "1.20.4" => "1-20-4"
  normalizeVersion = replaceStrings ["."] ["-"];

  # {version = "1.20.4";} => "1-20"
  majorMinorNormalized = package:
    normalizeVersion (majorMinor package.version);

  getVersion = set: (head (attrValues set)).version;

  isStable = version:
    (intersectLists (splitVersion version) ["pre" "rc"]) == [];
  filterUnstable = filter (el: isStable (getVersion el));

  highestVersion = versions: let
    versions' = filterUnstable versions;
  in
    foldl' (
      maxSet: set: let
        maxSetVersion = getVersion maxSet;
        setVersion = getVersion set;
      in
        if versionOlder setVersion maxSetVersion
        then maxSet // {version = maxSetVersion;}
        else set // {version = setVersion;}
    ) (head versions')
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
