/*
 * xbuild
 */
{ stdenv, fetchFromGitHub, rustPlatform, pkgs }:
rustPlatform.buildRustPackage rec {
  version = "v0.5.29";
  pname = "cargo-xbuild";

  src = fetchFromGitHub {
    owner = "rust-osdev";
    repo = "cargo-xbuild";
    rev = version;

    sha256 = "05wg1xx2mcwb9cplmrpg13jimddlzmv7hf5g3vjppjp8kz2gb7zj";
  };

  propagatedBuildInputs = [
    pkgs.ncurses
  ];

  cargoSha256 = "1pj8zfkr51y7lbjg9c3di4gr8a2l0z5gqslk6wmsiry6vcj2sks1";

  /*
   * Just copied from upstream crates.io
   */
  meta = with stdenv.lib; {
    description = "Automatically cross-compiles the sysroot crates core, compiler_builtins, and alloc.";
    homepage = https://github.com/rust-osdev/cargo-xbuild;
    maintainers = with maintainers; [ "phil-opp" ];
    license = with licenses; [ mit asl20 ];
    platforms = platforms.unix;
  };
}