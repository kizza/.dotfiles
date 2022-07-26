{ pkgs, ... }:

with import <nixpkgs> {};

let
  base16 = stdenv.mkDerivation rec {
    pname = "base16-shell";
    version = "1.0.0";

    srcs = [
      (pkgs.fetchFromGitHub {
        owner = "chriskempson";
        name = pname;
        repo = "base16-shell";
        rev = "ae84047d378700bfdbabf0886c1fb5bb1033620f";
        sha256 = "150sqmpi5f4bh4phnmjc3r1m15vhfcxrhbj36922lgqvw23bxb6j";
      })
      ./themes
    ];

    sourceRoot = pname;

    # Copy my themes into the /scripts directory
    buildPhase = ''
      cp -r ../themes/. ./scripts/
    '';

    # Copy everything to $out
    installPhase = ''
      cp -r . $out
    '';

    meta = with lib; {
      description = "Install base16-shell but with my custom themes";
    };
  };
in
{
  home = {
    file = {
      ".config/base16-shell".source = base16;
      ".vim/colors/base16-solarized-lighter.vim".text = builtins.readFile ./themes/base16-solarized-lighter.vim;
      ".vim/colors/base16-atelier-dune-lighter.vim".text = builtins.readFile ./themes/base16-atelier-dune-lighter.vim;
    };
  };
}