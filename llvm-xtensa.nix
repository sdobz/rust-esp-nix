{ stdenv, fetchFromGitHub, pkgs }:

stdenv.mkDerivation rec {
  name = "llvm-xtensa";
  version = "33d79cce656c8c85c38832c8f52810875a3fbddf";

  src = fetchFromGitHub {
    owner = "espressif";
    repo = "llvm-project";
    rev  = "${version}";
    fetchSubmodules = true;
    sha256 = "1a433q374in781l7sjavdlajrhbd568jdr540n2qlgzvkas44g4v";
  };

   buildInputs = [
     pkgs.python3
     pkgs.cmake
     pkgs.ninja
   ];

  phases = [ "unpackPhase" "buildPhase" "installPhase" "fixupPhase" ];

  # http://quickhack.net/nom/blog/2019-05-14-build-rust-environment-for-esp32.html
  buildPhase = ''
    mkdir llvm_build
    cd llvm_build
    cmake ../llvm -DLLVM_ENABLE_PROJECTS="clang;libc;libclc;libcxx;libcxxabi;libunwind;lld;parallel-libs" -DLLVM_INSTALL_UTILS=ON -DLLVM_EXPERIMENTAL_TARGETS_TO_BUILD="Xtensa" -DCMAKE_BUILD_TYPE=Release -G "Ninja"
    cmake --build .
  '';

  installPhase = ''
    mkdir -p $out
    cmake -DCMAKE_INSTALL_PREFIX=$out -P cmake_install.cmake
  '';

  meta = with stdenv.lib; {
    description = "LLVM xtensa";
    homepage = https://github.com/espressif/llvm-project;
    license = licenses.asl20;
  };
}
