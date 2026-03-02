packages: {
  config,
  lib,
  ...
}: let
  inherit
    (lib.modules)
    mkRemovedOptionModule
    mkIf
    ;
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
  inherit
    (lib.attrsets)
    optionalAttrs
    ;
  inherit (builtins) toJSON;

  cfg = config.programs.vs-launcher;

  settingsSubmodule = submodule {
    options = {
      installationsDir = mkOption {
        type = nullOr str;
        default = null;
        example = ".VSLauncher/installations";
        description = ''
          Path to the directory containing VS Launcher's installations.
        '';
      };
      versionsDir = mkOption {
        type = nullOr str;
        default = null;
        example = ".VSLauncher/gameVersions";
        description = ''
          Path to the directory containing VS Launcher's Vintage Story versions.

          Note that the `gameVersions` option does not use that directory.
        '';
      };
      backupDir = mkOption {
        type = nullOr str;
        default = null;
        example = ".VSLauncher/backups";
        description = ''
          Path to the directory containing VS Launcher's backups.
        '';
      };
      gameVersions = mkOption {
        type = listOf package;
        default = [];
        description = "List of Vintage Story packages to add in VS Launcher.";
      };
    };
  };
in {
  imports = [
    (mkRemovedOptionModule [
      "programs"
      "vs-launcher"
      "gameVersionsDir"
    ] "The option has been removed")
    (mkRemovedOptionModule [
      "programs"
      "vs-launcher"
      "installedVersions"
    ] "The option has been renamed to <programs.vs-launcher.settings.gameVersions>")
  ];

  options.programs.vs-launcher = {
    enable = mkEnableOption "VS Launcher";

    package = mkPackageOption packages "vs-launcher" {};

    settings = mkOption {
      type = settingsSubmodule;
      default = {};
      example = literalExpression ''
        {
          installationsDir = "''${config.xdg.configHome}/VSLauncher/installations";
          versionsDir = "''${config.xdg.configHome}/VSLauncher/gameVersions";
          backupDir = "''${config.xdg.configHome}/VSLauncher/backups";

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

    home.activation.updateVSLauncherGameVersions = let
      configDir =
        if config.xdg.enable
        then "${config.xdg.configHome}/VSLauncher"
        else "${config.home.homeDirectory}/.config/VSLauncher";

      gameVersions = toJSON (map (vintagestory: let
          merged = vintagestory.overrideAttrs {
            postFixup = ''
              mv $out/share/vintagestory/Vintagestory $out/share/vintagestory/Vintagestory-unwrapped
              ln -s $out/bin/vintagestory $out/share/vintagestory/Vintagestory
            '';
          };
        in {
          inherit (vintagestory) version;
          path = "${merged}/share/vintagestory";
        })
        cfg.settings.gameVersions);

      optionalOption = name: value: optionalAttrs (value != null) {${name} = value;};
      settings = toJSON (
        optionalOption "defaultInstallationsFolder" cfg.settings.installationsDir
        // optionalOption "defaultVersionsFolder" cfg.settings.versionsDir
        // optionalOption "backupsFolder" cfg.settings.backupDir
      );
    in
      lib.hm.dag.entryAfter ["writeBoundary"] ''
        set -euo pipefail

        mkdir -p "${configDir}"
        config_dir="${configDir}"
        if [ -f "$config_dir/config.json" ]; then
          run jq '.gameVersions = (.gameVersions | map(select(.path | startswith("/nix/store/") | not))) | .gameVersions += ${gameVersions}' \
            "$config_dir/config.json" > "$config_dir/config.json.tmp" && mv "$config_dir/config.json.tmp" "$config_dir/config.json"
          run jq '. += ${settings}' \
            "$config_dir/config.json" > "$config_dir/config.json.tmp" && mv "$config_dir/config.json.tmp" "$config_dir/config.json"
        else
          run echo '{"gameVersions": ${gameVersions}}' > "$config_dir/config.json"
          # Also create the 'installations' attribute or else, config is overwritten on launch
          run jq '. += ${settings} | . += {"installations":[]}' \
            "$config_dir/config.json" > "$config_dir/config.json.tmp" && mv "$config_dir/config.json.tmp" "$config_dir/config.json"
        fi
      '';
  };
}
