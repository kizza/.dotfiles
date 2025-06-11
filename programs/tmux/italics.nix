{ pkgs, ... }:

with import <nixpkgs> {};

stdenv.mkDerivation rec {
  pname = "screen-256italic";
  version = "1.0.0";

  src = ./screen-256color.terminfo;

  nativeBuildInputs = [
    ncurses
  ];

  dontUnpack = true;

  # infocmp was not returning my terminfo
  # even though infocmp -D showed ~/.terminfo as a valid directory
  # I *believe* it's because it wasn't compiled by the same `tic` binary
  # I am using `/usr/bin/tic` directly to fix this for now
  # ~${pkgs.ncurses}/bin/tic -x -o $out $src~
  installPhase = ''
    /usr/bin/tic -x -o $out $src
  '';

  meta = with lib; {
    description = "Install the terminfo to use italics in tmux/vim";
  };
}
