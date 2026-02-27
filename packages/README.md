```
█▀█ ▄▀█ ▄▀▀ █▄▀ ▄▀█ █▀▀ █▀▀ █▀
█▀▀ █▀█ ▀▄▄ █░█ █▀█ █▄█ ██▄ ▄█
```

---

<p align="center">
This directory contains all the packaged Vintage Story versions.
<br><br><b>🧭 Navigation</b><br>
<kbd><a href="https://github.com/PierreBorine/vintagestory-nix"><b>🏠Home</b></a></kbd>
<kbd><a href="https://github.com/PierreBorine/vintagestory-nix/tree/master/tools"><b>🔧Tools</b></a></kbd>
</p>

## Usage
The recommended way is to use the overlay

```nix
# configuration.nix
{inputs, ...}: {
  nixpkgs = {
    overlays = [inputs.vintagestory-nix.overlays.default];
  };
}
```

You can then access all packages through the `vintagestoryPackages` namespace.
```nix
{pkgs, ...}:
with pkgs.vintagestoryPackages; [
  # Select a specific, fixed version.
  v1-20-4

  # Select a minor version.
  # Will get updated if a new patch of that version is packaged.
  v1-20

  # Select the latest packaged version.
  latest

  # Select a .NET8 patched version
  v1-19-7-net8
  v1-20-net8
]
```

##### Example
```nix
{pkgs, ...}: {
  home.packages = [pkgs.vintagestoryPackages.latest];

  programs.vs-launcher = {
    enable = true;
    settings.gameVersions = with pkgs.vintagestoryPackages; [
      v1-19-6-net8
      v1-21-0
    ];
  };
}
```

> [!TIP]
> Get the full list of packages using the following command:
> ```sh
> nix flake show github:PierreBorine/vintagestory-nix
> ```

## "`-net8`" packages
Before 1.21, Vintage Story used .NET 7 which had reached End-Of-Life on the 14th of May 2024,
this means its package was marked as insecure on nixpkgs.

Trying to install an older version throws an error if you didn't add `dotnet-runtime-7.0.20` to your `permittedInsecurePackages`.

This flake provides packages suffixed with `-net8` for versions up to 1.20.12 that subtitute .NET7 with .NET8.

I did not encounter issues in my playtime with these packages so I assume they are safe to use.

> [!NOTE]
> As of 1.21, Vintage Story officially uses .NET8 so this is not needed anymore.

## Use Wayland instead of X11/XWayland
[Since 1.21](https://www.vintagestory.at/forums/topic/16744-v1210-rc3-story-chapter-2-redux/#comment-80623), Vintage Story supports running a Wayland native window.

Please note that X11 is still the default as VS on Wayland currently has scaling issues and generally less FPS.
```nix
{pkgs, ...}: {
  home.packages = [
    (pkgs.vintagestoryPackages.v1-21.override {
      waylandSupport = true;
      x11Support = false; # optional
    })
  ];
}
```
Enabling both will make Vintage Story default to Wayland and fallback to X11.

## A new Vintage Story version is out and I want it now !
You can install pretty much any version with the `mkVintageStory` function.

Do note that this method may not work if the new version got substantial changes
to the point it requiers an updated derivation.
```nix
{inputs, ...}: {
  home.packages = [
    (inputs.vintagestory-nix.lib.mkVintageStory {
      version = "1.24.8";
      hash = "sha256-Hgp2u/y2uPnJhAmPpwof76/woFGz4ISUXU+FIRMjMuQ=";
    })
    # Unstable release (release candidate, ...)
    (inputs.vintagestory-nix.lib.mkVintageStory {
      version = "1.28.4-rc.2";
      hash = "sha256-fCSJu7qnU8kC4tisJLlUQV9zlET7oDU/MkbCpu7ISzg=";
    })
  ];
}
```
