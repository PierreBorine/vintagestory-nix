```
▀█▀ █▀█ █▀█ █░░ █▀
░█░ █▄█ █▄█ █▄▄ ▄█
```

---

<p align="center">
This directory contains packages and home-manager modules for some modding tools.
<br><br><b>🧭 Navigation</b><br>
<kbd><a href="https://github.com/PierreBorine/vintagestory-nix/tree/master/packages"><b>📦Packages</b></a></kbd>
<kbd><a href="https://github.com/PierreBorine/vintagestory-nix"><b>🏠Home</b></a></kbd>
</p>

## Packages

- `rustique`
- `vs-launcher`
- `vsmodelcreator`

## Home-Manager modules

- `default` (all modules)
- `vs-launcher`

## Rustique

[Rustique](https://github.com/Tekunogosu/Rustique) is a Rust command-line interface,
for managing and updating Vintage Story mods and their dependencies.

It works the same way as an Operating System package manager.

## VS Launcher

[VS Launcher](https://github.com/XurxoMF/vs-launcher) is an Electron-based
game versions and mods manager.<br>
You can easily create isolated installations of Vintage Story to have different
modpacks at different game versions.

> [!IMPORTANT]
> Vintage Story versions installed through the in-app downloader won't start on NixOS.

**Maximal example**

```nix
# home.nix
{inputs, pkgs, ...}: {
  imports = [inputs.vintagestory-nix.homeModules.vs-launcher];

  programs.vs-launcher = {
    enable = true; # Install VS Launcher
    package = pkgs.vintagestoryPackages.vs-launcher; # default
    settings = {
      # These are 'null' by default
      installationsDir = "${config.xdg.configHome}/VSLauncher/installations";
      versionsDir = "${config.xdg.configHome}/VSLauncher/gameVersions";
      backupDir = "${config.xdg.configHome}/VSLauncher/backups";

      # List of Vintage Story packages to install in VS Launcher
      gameVersions = with pkgs.vintagestoryPackages; [
        # Old save with lots of mods, some of them
        # never got updated
        v1-19-6-net8

        # I have an active save with some friends
        v1-21-0
      ];
    };
  };

  # Can still have a standalone install
  home.packages = [pkgs.vintagestoryPackages.latest];
}
```

## VS Model Creator

[VS Model Creator](https://github.com/anegostudios/vsmodelcreator) is the
official tool for creating and animating blocks, items and entities for Vintage Story.

Here is [a link](https://wiki.vintagestory.at/Modding:VS_Model_Creator) to
the wiki with guides on how to use the software.

> [!NOTE]
> I haven't extensively tested this one but it worked well in my toying.
>
> Anyhow, if you find any packaging-related issue, do not hesitate reporting it.
