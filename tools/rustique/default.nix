{
  lib,
  rustPlatform,
  fetchFromGitHub,
  installShellFiles,
  cacert,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "rustique";
  version = "0.6.0";

  src = fetchFromGitHub {
    owner = "Tekunogosu";
    repo = "Rustique";
    rev = "v${finalAttrs.version}";
    hash = "sha256-f8QtVzdWnKp+5hGi+y+XRyVq3Ai10u9GEmJKitM1DZQ=";
  };

  nativeBuildInputs = [
    installShellFiles
    cacert # needed, even when only generating shell completions
  ];

  # tries to use clang and /usr/bin/mold, let's just not do that, and
  # use the GNU toolchain from stdenv
  postPatch = "rm -vf .cargo/config.toml";

  # Fails to fetch some dependencies when computing `cargoHash`
  cargoLock.lockFile = "${finalAttrs.src}/Cargo.lock";

  postInstall = ''
    mv $out/bin/rustique-cli $out/bin/rustique

    # Rustique needs to write config files before doing anything
    export HOME=$(mktemp -d)
    $out/bin/rustique misc

    installShellCompletion --cmd rustique \
      --bash <($out/bin/rustique misc -g bash) \
      --fish <($out/bin/rustique misc -g fish) \
      --zsh <($out/bin/rustique misc -g zsh)
  '';

  meta = {
    description = "The best Vintage Story mod manager you've never used";
    homepage = "https://github.com/Tekunogosu/Rustique";
    changelog = "https://github.com/Tekunogosu/Rustique/blob/${finalAttrs.src.rev}/changelog.md";
    license = lib.licenses.mit;
    mainProgram = "rustique";
  };
})
