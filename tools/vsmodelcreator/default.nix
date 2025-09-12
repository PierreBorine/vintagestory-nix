{
  lib,
  stdenv,
  fetchFromGitHub,
  copyDesktopItems,
  makeDesktopItem,
  makeWrapper,
  xorg,
  libGL,
  jdk8,
  jre8,
  ant,
}:
stdenv.mkDerivation rec {
  pname = "vsmodelcreator";
  version = "18Sep2024";

  src = fetchFromGitHub {
    owner = "anegostudios";
    repo = "vsmodelcreator";
    rev = version;
    hash = "sha256-l6rH+WU393cZ2MOM3+K8slV9gEFSL/cHjSychcbf74Y=";
  };

  nativeBuildInputs = [
    copyDesktopItems
    makeWrapper
    jdk8
    ant
  ];

  patchPhase = ''
    sed -i "s|^\(.*\)./natives/linux/\(.*\)|\1$out/share/vsmodelcreator/natives/linux/\2|" src/at/vintagestory/modelcreator/Start.java
  '';

  buildPhase = "ant";

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share

    cp -r output/linux $out/share/vsmodelcreator
    install -Dm644 bin/linux/appicon_128x.png $out/share/icons/hicolor/128x128/apps/vsmodelcreator.png

    makeWrapper ${lib.getExe jre8} $out/bin/vsmodelcreator \
      --add-flags "-cp $out/share/vsmodelcreator/vsmodelcreator.jar at.vintagestory.modelcreator.Start" \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath (with xorg; [libXxf86vm libGL])} \
      --prefix PATH : ${lib.makeBinPath [xorg.xrandr]}

    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "vsmodelcreator";
      desktopName = "VS Model Creator";
      exec = "vsmodelcreator %U";
      icon = "vsmodelcreator";
      genericName = "Vintage Story Model Creator";
      comment = "Vintage Story Model Creator";
      keywords = [
        "editor"
        "vintage"
        "models"
      ];
      categories = [
        "Application"
        "Utility"
        "Game"
      ];
    })
  ];

  meta = {
    description = "Vintage Story Model Creator";
    homepage = "https://github.com/anegostudios/vsmodelcreator";
    license = lib.licenses.asl20;
    mainProgram = "vsmodelcreator";
    platforms = lib.platforms.linux;
  };
}
