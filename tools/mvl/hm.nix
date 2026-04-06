packages: {
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.attrsets) optionalAttrs;
  inherit (lib.strings) toJSON;
  inherit
    (lib.options)
    literalExpression
    mkEnableOption
    mkPackageOption
    mkOption
    ;
  inherit
    (lib.types)
    submodule
    package
    listOf
    nullOr
    str
    ;

  cfg = config.programs.mvl;

  settingsSubmodule = submodule {
    options = {
      releaseFolder = mkOption {
        type = nullOr str;
        default = null;
        example = ".MVL/Release";
        description = ''
          Path to the directory containing MVL's Vintage Story releases.
        '';
      };
      modpackFolder = mkOption {
        type = nullOr str;
        default = null;
        example = ".MVL/Modpack";
        description = ''
          Path to the directory containing MVL modpacks.

          Note that the `gameVersions` option does not use that directory.
        '';
      };
      gameVersions = mkOption {
        type = listOf package;
        default = [];
        description = "List of Vintage Story packages to add in MVL.";
      };
    };
  };
in {
  options.programs.mvl = {
    enable = mkEnableOption "MVL";

    package = mkPackageOption packages "mvl" {};

    settings = mkOption {
      type = settingsSubmodule;
      default = {};
      example = literalExpression ''
        {
          releaseFolder = ".MVL/Release";
          modpackFolder = ".MVL/Modpack";

          gameVersions = with pkgs.vintagestoryPackages; [
            v1-21-1
            v1-21-2-rc-2
          ];
        }
      '';
    };
  };

  config = mkIf cfg.enable {
    home.packages = [cfg.package];

    home.activation.updateMVLReleases = let
      configDir =
        if config.xdg.enable
        then "${config.xdg.dataHome}/MVL"
        else "${config.home.homeDirectory}/.local/share/MVL";

      gameVersions = toJSON (map (vintagestory: let
        merged = vintagestory.overrideAttrs {
          postFixup = ''
            mv $out/share/vintagestory/Vintagestory $out/share/vintagestory/Vintagestory-unwrapped
            ln -s $out/bin/vintagestory $out/share/vintagestory/Vintagestory
          '';
        };
      in "${merged}/share/vintagestory")
      cfg.settings.gameVersions);

      optionalOption = name: value: optionalAttrs (value != null) {${name} = value;};
      settings = toJSON (
        optionalOption "modpackFolder" cfg.settings.modpackFolder
        // optionalOption "releaseFolder" cfg.settings.releaseFolder
      );
    in
      lib.hm.dag.entryAfter ["writeBoundary"] ''
        set -euo pipefail

        mkdir -p "${configDir}"
        config_dir="${configDir}"
        if [ -f "$config_dir/data.json" ]; then
          run jq '.release = (.release | map(select(startswith("/nix/store/") | not))) | .release += ${gameVersions}' \
            "$config_dir/data.json" > "$config_dir/data.json.tmp" && mv "$config_dir/data.json.tmp" "$config_dir/data.json"
          run jq '. += ${settings}' \
            "$config_dir/data.json" > "$config_dir/data.json.tmp" && mv "$config_dir/data.json.tmp" "$config_dir/data.json"
        else
          run echo '{"release": ${gameVersions}}' > "$config_dir/data.json"
        fi
      '';
  };
}
