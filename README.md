<p align="center">
█░█ ▀█▀ █▄░█ ▀█▀ ▄▀█ █▀▀ █▀▀ █▀ ▀█▀ █▀█ █▀█ ▀▄▀ ▄▄ █▄░█ ▀█▀ ▀▄▀<br>
▀▄▀ ▄█▄ █░▀█ ░█░ █▀█ █▄█ ██▄ ▄█ ░█░ █▄█ █▀▄ ░█░ ░░ █░▀█ ▄█▄ ▄▀▄
</p>

---

<p align="center">
A flake to help you on your
<a href="https://www.vintagestory.at">Vintage Story</a> journey on NixOS.
<br><br><b>🧭 Navigation</b><br>
<kbd><a href="https://github.com/PierreBorine/vintagestory-nix/tree/master/packages"><b>📦Packages</b></a></kbd>
<kbd><a href="https://github.com/PierreBorine/vintagestory-nix/tree/master/tools"><b>🔧Tools</b></a></kbd>
</p>

## Features

### 📦 All game versions, down to 1.18.8

Get the full list using the following command:

```shell
nix flake show github:PierreBorine/vintagestory-nix
```

### 🧪 Release Candidates

### 🛡️ .NET 7 free packages (pre 1.21)

### 🔧 Modding tools with Home Manager modules

- **VS Launcher** (unfree) - [github](https://github.com/XurxoMF/vs-launcher) -
[moddb](https://mods.vintagestory.at/show/mod/16326)
- **Rustique** (MIT) - [github](https://github.com/Tekunogosu/Rustique) -
[moddb](https://mods.vintagestory.at/rustique)
- **VS Model Creator** (Apache 2.0) -
[github](https://github.com/anegostudios/vsmodelcreator) -[wiki](https://wiki.vintagestory.at/Modding:VS_Model_Creator)

## Usage

Add this flake as an input to yours

```nix
# flake.nix
inputs = {
  vintagestory-nix = {
    url = "github:PierreBorine/vintagestory-nix";
    inputs.nixpkgs.follows = "nixpkgs";
  };
};
```

Add the overlay

```nix
# configuration.nix
{inputs, ...}: {
  nixpkgs.overlays = [inputs.vintagestory-nix.overlays.default];
}
```

### Vintage Story packages

See the [relevant README](https://github.com/PierreBorine/vintagestory-nix/tree/master/packages)
for more complete docs.

```nix
{pkgs, ...}: {
  home.packages = [
    pkgs.vintagestoryPackages.v1-20-12
    pkgs.vintagestoryPackages.v1-21-1-rc-2
    pkgs.vintagestoryPackages.v1-19  # ignores RCs
    pkgs.vintagestoryPackages.latest # ignores RCs
  ];
}
```

### Modding Tools

See the [relevant README](https://github.com/PierreBorine/vintagestory-nix/tree/master/tools)
for more complete docs.

```nix
{inputs, pkgs, ...}: {
  imports = [inputs.vintagestory-nix.homeModules.default];

  home.packages = [
    pkgs.vintagestoryPackages.rustique
    pkgs.vintagestoryPackages.vs-launcher
  ];

  # Recommended !!
  # As the builtin game downloader
  # won't work on NixOS.
  programs.vs-launcher = {
    enable = true;
    settings.gameVersions = [
      pkgs.vintagestoryPackages.v1-21-1
    ];
  };
}
```

### Server

See the [module file](https://github.com/PierreBorine/vintagestory-nix/tree/master/module/default.nix)
for more infos

```nix
# configuration.nix
{inputs, pkgs, ...}: {
  imports = [inputs.vintagestory-nix.nixosModules.default];

  services.vintagestory = {
    enable = true;
    package = pkgs.vintagestoryPackages.v1-21-0;
    openFirewall = true;
  };
}
```

## Installing mods with Nix

This flake does not provide a way to declaratively install mods with Nix.
Fortunately for you, [vs2nix](https://github.com/dtomvan/vs2nix) is another
Vintage Story flake that packages the top 400 mods of modDB.

## Thanks

- to the [Vintage Story team](https://www.vintagestory.at/aboutus.html)
for their incredible game
- to [XurxoMF](https://github.com/XurxoMF) for making VS Launcher
- to [Vixenin](https://github.com/NixOS/nixpkgs/issues/360384#issuecomment-2557412151)
for the .NET8 trick
- to [dtomvan](https://github.com/dtomvan/vs2nix/blob/main/parts/programs/rustique.nix)
for the rustique derivation and the [server module](https://github.com/NixOS/nixpkgs/pull/414845)
