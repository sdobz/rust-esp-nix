{ pkgs, rustPlatform }:

rec {
  rust-analyzer-unwrapped = pkgs.callPackage (pkgs.path + /pkgs/development/tools/rust/rust-analyzer/generic.nix) rec {
    inherit rustPlatform;
    rev = "2020-05-11";
    version = "unstable-${rev}";
    sha256 = "07sm3kqqva2jw41hb3smv3h3czf8f5m3rsrmb633psb1rgbsvmii";
    cargoSha256 = "1x1nkaf10lfa9xhkvk2rsq7865d9waxw0i4bg5kwq8kz7n9bqm90";
  };

  rust-analyzer = pkgs.callPackage (pkgs.path + /pkgs/development/tools/rust/rust-analyzer/wrapper.nix) {
    inherit rustPlatform;
  } {
    unwrapped = rust-analyzer-unwrapped;
  };
}
