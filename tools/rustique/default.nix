{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:
rustPlatform.buildRustPackage rec {
  pname = "Rustique";
  version = "0.5.11";

  src = fetchFromGitHub {
    owner = "Tekunogosu";
    repo = "Rustique";
    rev = "v${version}";
    hash = "sha256-aVop4ZO+mufkguU5+yTpyAtWlZ5u5J5QSo1xhJh7afc=";
  };

  # tries to use clang and /usr/bin/mold, let's just not do that, and
  # use the GNU toolchain from stdenv
  postPatch = "rm -vf .cargo/config.toml";

  cargoHash = "sha256-pIaMiPe3OW6JU5NKUhsVHNsvYvQdIVs1swhWz0wPn08=";

  # unstable rust feature path_add_extension
  env.RUSTC_BOOTSTRAP = 1;

  meta = {
    description = "The best Vintage Story mod manager you've never used";
    homepage = "https://github.com/Tekunogosu/Rustique";
    changelog = "https://github.com/Tekunogosu/Rustique/blob/${src.rev}/changelog.md";
    license = lib.licenses.mit;
    mainProgram = "rustique-cli";
  };
}
