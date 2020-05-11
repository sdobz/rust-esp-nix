{ stdenv, fetchFromGitHub, pkgs, makeWrapper }:

let
  version = "0a03a55c1eb44a354c9ad5d91d91da371fe23f84";

  pypkgs = python-packages: with python-packages; [
    pyserial
    click
    cryptography
    future
    pyparsing
    pyelftools
    setuptools
    pip
  ];
  python = pkgs.python2.withPackages pypkgs;

in stdenv.mkDerivation rec {
  name = "esp-idf";

  inherit python;

  src = fetchFromGitHub {
    owner = "espressif";
    repo = "esp-idf";
    rev  = "${version}";
    fetchSubmodules = true;
    sha256 = "067rgddhh4fdpnarxz7qjhfb377zdppgk8xsjqpkc07rdyagmwx6";
  };

  propagatedBuildInputs = [
    pkgs.cmake
    pkgs.ninja
    pkgs.gcc
    pkgs.git
    pkgs.ncurses
    pkgs.flex
    pkgs.bison
    pkgs.gperf
    pkgs.ccache
    python
  ];

  phases = [ "unpackPhase" "installPhase" "fixupPhase" ];

  installPhase = ''
    cp -r . $out
  '';

  meta = with stdenv.lib; {
    description = "ESP IDF";
    homepage = https://docs.espressif.com/projects/esp-idf/en/stable/get-started/linux-setup.html;
    license = licenses.gpl3;
  };
}