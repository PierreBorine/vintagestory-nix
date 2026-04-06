{
  lib,
  fetchurl,
  appimageTools,
  makeDesktopItem,
}: let
  version = "1.0.0";
  pname = "mvl";

  src = fetchurl {
    url = "https://github.com/scgm0/MVL/releases/download/${version}/MVL-${version}.AppImage";
    hash = "sha256-KKZsMzU2NXRPJMjXLVxGLjD3maBeFIm8N733NUUtWdc=";
  };

  appimageContents = appimageTools.extractType1 {inherit pname src version;};

  desktopItem = makeDesktopItem {
    name = "mvl";
    desktopName = "MVL";
    exec = "mvl %U";
    icon = "mvl";
    genericName = "Vintage Story Launcher";
    comment = "MystiVaid's VintageStory Launcher";
    keywords = [
      "vintage"
      "launcher"
      "mods"
      "manager"
    ];
    categories = [
      "Application"
      "Utility"
      "Game"
    ];
  };
in
  appimageTools.wrapType2 {
    inherit pname version src;

    extraPkgs = pkgs: [
      (with pkgs.dotnetCorePackages;
        combinePackages [
          runtime_8_0
          runtime_10_0
        ])
    ];

    extraInstallCommands = ''
      install -D ${appimageContents}/icon.svg $out/share/icons/hicolor/scalable/apps/mvl.svg

      install -Dm644 ${desktopItem}/share/applications/mvl.desktop \
        $out/share/applications/mvl.desktop
    '';

    meta = {
      description = "A free, open-source, community-driven launcher for Vintage Story";
      homepage = "https://mods.vintagestory.at/mvl";
      downloadPage = "https://github.com/scgm0/MVL/releases";
      license = lib.licenses.mit;
      sourceProvenance = with lib.sourceTypes; [binaryNativeCode];
      platforms = lib.platforms.linux;
      mainProgram = "mvl";
    };
  }
