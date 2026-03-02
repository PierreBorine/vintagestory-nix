{
  lib,
  stdenv,
  fetchzip,
  makeWrapper,
  makeDesktopItem,
  copyDesktopItems,
  cairo,
  libGLU,
  libglvnd,
  pipewire,
  libpulseaudio,
  dotnet-runtime_8,
  x11Support ? true,
  libX11 ? null,
  libXi ? null,
  libXcursor ? null,
  waylandSupport ? false,
  wayland ? null,
  libxkbcommon ? null,
  version,
  hash,
  unstable ? null,
}:

assert x11Support || waylandSupport;
assert x11Support -> libX11 != null;
assert x11Support -> libXi != null;
assert x11Support -> libXcursor != null;
assert waylandSupport -> wayland != null;
assert waylandSupport -> libxkbcommon != null;

stdenv.mkDerivation (finalAttrs: {
  pname = "vintagestory";
  inherit version;

  src =
    let
      version_split = builtins.splitVersion version;
      stability =
        lib.warnIf (unstable != null) ''
            vintagestory-nix: Calling `mkVintageStory` with `unstable` is deprecated.
            Version stability is now determined automatically from the version string.
        '' (
        if builtins.elem "pre" version_split
        then "pre"
        else if builtins.elem "rc" version_split
        then "unstable"
        else "stable"
      );
    in
    fetchzip {
      url = "https://cdn.vintagestory.at/gamefiles/${stability}/vs_client_linux-x64_${version}.tar.gz";
      ${
        if lib.hasSuffix "sha256-" hash
        then "hash"
        else "sha256"
      } =
        hash;
    };

  nativeBuildInputs = [
    makeWrapper
    copyDesktopItems
  ];

  runtimeLibs =
    [
      cairo
      libGLU
      libglvnd
      pipewire
      libpulseaudio
    ]
    ++ lib.optionals x11Support [
      libX11
      libXi
      libXcursor
    ]
    ++ lib.optionals waylandSupport [
      wayland
      libxkbcommon
    ];

  desktopItems = [
    (makeDesktopItem {
      name = "vintagestory";
      desktopName = "Vintage Story";
      exec = "vintagestory";
      icon = "vintagestory";
      comment = "Innovate and explore in a sandbox world";
      categories = ["Game"];
    })
    (makeDesktopItem {
      name = "vsmodinstall-handler";
      desktopName = "Vintage Story 1-click Mod Install Handler";
      comment = "Handler for vintagestorymodinstall:// URI scheme";
      exec = "vintagestory -i %u";
      mimeTypes = ["x-scheme-handler/vintagestorymodinstall"];
      noDisplay = true;
      terminal = false;
    })
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/vintagestory $out/bin $out/share/pixmaps $out/share/fonts/truetype
    cp -r * $out/share/vintagestory
    cp $out/share/vintagestory/assets/gameicon.xpm $out/share/pixmaps/vintagestory.xpm
    cp $out/share/vintagestory/assets/game/fonts/*.ttf $out/share/fonts/truetype

    rm -rvf $out/share/vintagestory/{install,run,server}.sh

    runHook postInstall
  '';

  preFixup = let
    runtimeLibs' = lib.strings.makeLibraryPath finalAttrs.runtimeLibs;
    wrapperFlags = lib.trim ''
      --prefix LD_LIBRARY_PATH : "${runtimeLibs'}" \
      ${lib.strings.optionalString waylandSupport ''
        --set-default OPENTK_4_USE_WAYLAND 1 \
      ''} \
      --set-default mesa_glthread true
    '';
  in ''
    makeWrapper ${lib.meta.getExe dotnet-runtime_8} $out/bin/vintagestory \
      ${wrapperFlags} \
      --add-flags $out/share/vintagestory/Vintagestory.dll
    makeWrapper ${lib.meta.getExe dotnet-runtime_8} $out/bin/vintagestory-server \
      ${wrapperFlags} \
      --add-flags $out/share/vintagestory/VintagestoryServer.dll

    find "$out/share/vintagestory/assets/" -not -path "*/fonts/*" -regex ".*/.*[A-Z][^/]*" | while read -r file; do
      local filename="$(basename -- "$file")"
      ln -sf "$filename" "''${file%/*}"/"''${filename,,}"
    done
  '';

  meta = {
    description = "In-development indie sandbox game about innovation and exploration";
    homepage = "https://www.vintagestory.at";
    license = lib.licenses.unfree;
    sourceProvenance = [lib.sourceTypes.binaryBytecode];
    platforms = ["x86_64-linux"];
    mainProgram = "vintagestory";
  };
})
