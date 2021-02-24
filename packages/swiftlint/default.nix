{ stdenv, lib }:

# This derivation is impure: it relies on an Xcode toolchain being installed
# and available in the expected place. The build_with_disable_sandbox and
# prefix_install variants of build and install seem to have been added for Brew
# compat and well, they work here too.

stdenv.mkDerivation rec {
  pname = "swiftlint";
  version = "0.42.0";

  src = (import ../../nix/sources.nix).SwiftLint;

  preConfigure = "LD=$CC";

  buildPhase = ''
    PATH=/usr/bin:$PATH \
      make build_with_disable_sandbox
  '';

  installPhase = ''
    PATH=/usr/bin:$PATH \
      PREFIX=$out \
      make prefix_install
  '';

  meta = with lib; {
    description = "A tool to enforce Swift style and conventions, loosely based on GitHub's Swift Style Guide";
    homepage = "https://github.com/realm/SwiftLint";
    license = licenses.mit;
    maintainers = [];
    platforms = platforms.darwin;
    hydraPlatforms = [];
  };
}
