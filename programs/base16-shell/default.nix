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
        rev = "588691ba71b47e75793ed9edfcfaa058326a6f41";
        sha256 = "X89FsG9QICDw3jZvOCB/KsPBVOLUeE7xN3VCtf0DD3E=";
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

      # Vim
      ".vim/colors/base16-solarized-lighter.vim".text = builtins.readFile ./themes/base16-solarized-lighter.vim;
      ".vim/colors/base16-atelier-dune-lighter.vim".text = builtins.readFile ./themes/base16-atelier-dune-lighter.vim;
      ".vim/colors/base16-gruvbox-dark-medium-custom.vim".text = builtins.readFile ./themes/base16-gruvbox-dark-medium-custom.vim;
      ".vim/colors/base16-joker.vim".text = builtins.readFile ./themes/base16-joker.vim;

      # Neovim
      ".config/nvim/colors/base16-solarized-lighter.vim".text = builtins.readFile ./themes/base16-solarized-lighter.vim;
      ".config/nvim/colors/base16-atelier-dune-lighter.vim".text = builtins.readFile ./themes/base16-atelier-dune-lighter.vim;
      ".config/nvim/colors/base16-gruvbox-dark-medium-custom.vim".text = builtins.readFile ./themes/base16-gruvbox-dark-medium-custom.vim;
      ".config/nvim/colors/base16-joker.vim".text = builtins.readFile ./themes/base16-joker.vim;
    };
  };
}
