{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "Rustique";
  version = "0.5.14";

  src = fetchFromGitHub {
    owner = "Tekunogosu";
    repo = "Rustique";
    rev = "v${finalAttrs.version}";
    hash = "sha256-3zKOEI6l2wUznO6sB0QDpEBiwFciQ3kHpbC+DMw0CyM=";
  };

  # tries to use clang and /usr/bin/mold, let's just not do that, and
  # use the GNU toolchain from stdenv
  postPatch = "rm -vf .cargo/config.toml";

  cargoHash = "sha256-ZXbpTV2pGUPwK9DTxiTLGC6M9I+KYxcr0109GkFFuKs=";

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
