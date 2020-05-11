{pkgs}:
let
    llvm-xtensa = (pkgs.callPackage ./llvm-xtensa.nix {});
    lib = pkgs.lib;
    lists = lib.lists;
    fetchCargoTarball = pkgs.callPackage (pkgs.path + /pkgs/build-support/rust/fetchCargoTarball.nix) {};

    toRustTarget = platform: with platform.parsed; let
        cpu_ = {
            "armv7a" = "armv7";
            "armv7l" = "armv7";
            "armv6l" = "arm";
        }.${cpu.name} or platform.rustc.arch or cpu.name;
        in platform.rustc.config
        or "${cpu_}-${vendor.name}-${kernel.name}${lib.optionalString (abi.name != "unknown") "-${abi.name}"}";

    # bootstrap
    date = "2020-03-12";
    # from rust-xtensa github
    version = "1.44.0";

    rustBinary = pkgs.callPackage (pkgs.path + /pkgs/development/compilers/rust/binary.nix) rec {
        # Noted while installing out of band
        # https://static.rust-lang.org/dist/2020-03-12/rust-std-beta-x86_64-unknown-linux-gnu.tar.xz
        # https://static.rust-lang.org/dist/2020-03-12/rustc-beta-x86_64-unknown-linux-gnu.tar.xz
        # https://static.rust-lang.org/dist/2020-03-12/cargo-beta-x86_64-unknown-linux-gnu.tar.xz
        # https://static.rust-lang.org/dist/2020-01-31/rustfmt-nightly-x86_64-unknown-linux-gnu.tar.xz

        # noted by inspecting https://static.rust-lang.org/dist/2020-03-12
        # version = "1.42.0";
        # version = "nightly";
        version = "beta";

        platform = toRustTarget pkgs.stdenv.hostPlatform;
        versionType = "bootstrap";

        src = pkgs.fetchurl {
            url = "https://static.rust-lang.org/dist/${date}/rust-${version}-${platform}.tar.gz";
            # sha256 = "0llhg1xsyvww776d1wqaxaipm4f566hw1xyy778dhcwakjnhf7kx"; # 1.42.0
            # sha256 = "0jhggcwr852c4cqb4qv9a9c6avnjrinjnyzgfi7sx7n1piyaad43"; # nightly
            sha256 = "1cv402wp9dx6dqd9slc8wqsqkrb7kc66n0bkkmvgjx01n1jhv7n5"; # beta
        };
    };
    bootstrapPlatform = pkgs.makeRustPlatform rustBinary;

    src = pkgs.fetchFromGitHub {
        owner = "MabezDev";
        repo = "rust-xtensa";
        # rust 1.42++
        rev  = "25ae59a82487b8249b05a78f00a3cc35d9ac9959";
        fetchSubmodules = true;
        sha256 = "1xr8rayvvinf1vahzfchlkpspa5f2nxic1j2y4dgdnnzb3rkvkg5";
    };
in
rec {
    rust-src = src;

    rustc = (pkgs.rustc.override {
        rustPlatform = bootstrapPlatform;
    # override the rustc result attrs before calling
    }).overrideAttrs ( old: rec {
        pname = "rustc-xtensa";
        inherit version src;

        llvmSharedForBuild = llvm-xtensa;
        llvmSharedForHost = llvm-xtensa;
        llvmSharedForTarget = llvm-xtensa;
        llvmShared = llvm-xtensa;
        patches = [];

        configureFlags = 
            (lists.remove "--enable-llvm-link-shared"
            (lists.remove "--release-channel=stable" old.configureFlags)) ++ [
            "--set=build.rustfmt=${pkgs.rustfmt}/bin/rustfmt"
            "--llvm-root=${llvm-xtensa}"
            "--experimental-targets=Xtensa"
            # Nightly because xargo (which compiles a new core) can only build on nightly
            # xargo replace with cargo xbuild
            "--release-channel=nightly"
        ];

        cargoDeps = fetchCargoTarball {
            inherit pname;
            inherit src;
            sourceRoot = null;
            srcs = null;
            patches = [];
            sha256 = "0z4mb33f72ik8a1k3ckbg3rf6p0403knx5mlagib0fs2gdswg9w5";
        };

        postConfigure = ''
            ${old.postConfigure}
            unpackFile "$cargoDeps"
            mv $(stripHash $cargoDeps) vendor
            # export VERBOSE=1
        '';
    });

    cargo = (pkgs.callPackage (pkgs.path + /pkgs/development/compilers/rust/cargo.nix) {
        rustPlatform = bootstrapPlatform;
        inherit (pkgs.darwin.apple_sdk.frameworks) Security CoreFoundation; 
        inherit rustc;
    }).overrideAttrs(old: rec {
        name = "cargo-xtensa-${version}";
        inherit version src;
        cargoDeps = fetchCargoTarball {
            inherit name;
            inherit src;
            sourceRoot = null;
            srcs = null;
            patches = [];
            sha256 = "1w5fz966vf09p87xbxc5pm9xq4f1gx8a2vj7fskx30skkwb97d13";
        };

        # cargoVendorDir = builtins.trace "${cargoDeps}" null;
        postConfigure = ''
            unpackFile "$cargoDeps"
            mv $(stripHash $cargoDeps) vendor
            # export VERBOSE=1
        '';
    });

    rustPlatform = pkgs.makeRustPlatform {
        inherit rustc cargo;
    };
}
