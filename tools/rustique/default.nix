{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "Rustique";
  version = "0.5.12";

  src = fetchFromGitHub {
    owner = "Tekunogosu";
    repo = "Rustique";
    rev = "v${finalAttrs.version}";
    hash = "sha256-5zdmujHdsDCmj4lVJFmdxZXjmOk0EaKCAQ5UWiv9HP0=";
  };

  # tries to use clang and /usr/bin/mold, let's just not do that, and
  # use the GNU toolchain from stdenv
  postPatch = "rm -vf .cargo/config.toml";

  # somehow, cargoHash fails to compute
  cargoLock.lockFile = "${finalAttrs.src}/Cargo.lock";

  # unstable rust feature path_add_extension
  env.RUSTC_BOOTSTRAP = 1;

  meta = {
    description = "The best Vintage Story mod manager you've never used";
    homepage = "https://github.com/Tekunogosu/Rustique";
    changelog = "https://github.com/Tekunogosu/Rustique/blob/${finalAttrs.src.rev}/changelog.md";
    license = lib.licenses.mit;
    mainProgram = "rustique-cli";
  };
})
