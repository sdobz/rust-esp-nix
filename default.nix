{pkgs}:
let
  rust-xtensa = (pkgs.callPackage ./rust-xtensa.nix { });
in rec {
  inherit (rust-xtensa) rustc cargo rust-src rustPlatform;
  esp-idf = pkgs.callPackage ./esp-idf.nix {};
  esp32-toolchain = pkgs.callPackage ./esp32-toolchain.nix {};
  llvm-xtensa = (pkgs.callPackage ./llvm-xtensa.nix {});

  xbuild = pkgs.callPackage ./xbuild.nix {
    inherit rustPlatform;
  };
  bindgen = pkgs.callPackage ./bindgen.nix {
    inherit rustPlatform;
  };
  env = ''
    export XARGO_RUST_SRC="${rust-src}/src"
    export LLVM_XTENSA="${llvm-xtensa}"
    export LIBCLANG_PATH="${llvm-xtensa}/lib"

    export IDF_PATH=${esp-idf}
    export IDF_TOOLS_PATH=${esp32-toolchain}

    export CFLAGS_COMPILE="-Wno-error=incompatible-pointer-types -Wno-error=implicit-function-declaration"
    export OPENOCD_SCRIPTS=$IDF_TOOLS_PATH/tools/openocd-esp32/share/openocd/scripts
    # export NIX_CFLAGS_LINK=-lncurses
    export PATH=$PATH:${esp-idf}/tools:${esp-idf}/components/esptool_py/esptool:$IDF_TOOLS_PATH/tools/esp32ulp-elf/bin:$IDF_TOOLS_PATH/tools/openocd-esp32/bin:$IDF_TOOLS_PATH/tools/xtensa-esp32-elf/bin
  '';
}