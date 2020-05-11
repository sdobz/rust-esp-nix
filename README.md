# RUST ESP32 NIX XTENSA ESP-IDF ESPRESSIF OH MY

This is a collection of nix files that support build rust onto the esp32

Example shell file:

shell.nix
```nix
let
  pythonPackageOverrides = self: super: {
    pyparsing = super.buildPythonPackage rec {
      pname = "pyparsing";
      version = "2.3.1";
      doCheck = false;
      src = super.fetchPypi {
        inherit pname version;
        sha256 = "0yk6xl885b91dmlhlsap7x78hk2rdr879fln9anbq6k4ca42djb6";
      };
    };
  };

  idf-package-overlay = self: super: {
    python2 = super.python2.override {
      packageOverrides = pythonPackageOverrides;
    };
  };

  pkgs = import (builtins.fetchTarball {
    # https://releases.nixos.org/nixos/unstable/nixos-20.09pre223023.fce7562cf46
    name = "nixos-unstable-2020-04-30";
    url = "https://github.com/nixos/nixpkgs/archive/fce7562cf46727fdaf801b232116bc9ce0512049.tar.gz";
    sha256 = "14rvi69ji61x3z88vbn17rg5vxrnw2wbnanxb7y0qzyqrj7spapx";
  }) {
    overlays = [
      idf-package-overlay
    ];
  };

  rust-esp = pkgs.callPackage ./rust-esp-nix {};
in 
pkgs.mkShell {
    buildInputs = [ 
      rust-esp.xbuild
      rust-esp.bindgen
      rust-esp.rustc
      rust-esp.cargo
      pkgs.rustfmt
    ];

    shellHook = ''
set -e

${rust-esp.env}

if ! [ -d esp-idf ]; then
  mkdir -p esp-idf
  cd esp-idf
  git init
  git remote add origin https://github.com/espressif/esp-idf
  git fetch --depth 1 origin 0a03a55c1eb44a354c9ad5d91d91da371fe23f84
  git checkout FETCH_HEAD
fi
    '';
}
```

Example usage:

```bash
$ git clone 
```

# Improvements:

* Bindgen is not running tests, needs investigation
* Package as an overlay so other rust based programs can use this version of rust
* Figure out how to not have to compile python to override a package
* More idiomatic nix?
