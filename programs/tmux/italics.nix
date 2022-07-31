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

  installPhase = ''
    tic -o $out $src
  '';

  meta = with lib; {
    description = "Install the terminfo to use italics in tmux/vim";
  };
}
