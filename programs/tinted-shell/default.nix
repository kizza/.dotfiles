{ pkgs, ... }:

with import <nixpkgs> {};

let
  tintedShell = stdenv.mkDerivation rec {
    pname = "tinted-shell";
    version = "1.0.0";

    srcs = [
      (pkgs.fetchFromGitHub {
        owner = "tinted-theming";
        name = pname;
        repo = "tinted-shell";
        rev = "839f96d22a5b3a702444b2b19513b2e751ff748a";
        sha256 = "yRFoqWanATVuxtNpw+cgORWY5MALnt131/yeCPPEk0I=";
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
      description = "Install tinted-shell but with my custom themes";
    };
  };
in
{
  home = {
    file = {
      ".config/tinted-theming/tinted-shell".source = tintedShell;

#       # Vim
#       ".vim/colors/base16-solarized-lighter.vim".text = builtins.readFile ./themes/base16-solarized-lighter.vim;
#       ".vim/colors/base16-atelier-dune-lighter.vim".text = builtins.readFile ./themes/base16-atelier-dune-lighter.vim;
#       ".vim/colors/base16-gruvbox-dark-medium-custom.vim".text = builtins.readFile ./themes/base16-gruvbox-dark-medium-custom.vim;
#       ".vim/colors/base16-joker.vim".text = builtins.readFile ./themes/base16-joker.vim;
#       ".vim/colors/base16-tokyonight.vim".text = builtins.readFile ./themes/base16-tokyonight.vim;

#       # Neovim
#       ".config/nvim/colors/base16-solarized-lighter.vim".text = builtins.readFile ./themes/base16-solarized-lighter.vim;
#       ".config/nvim/colors/base16-atelier-dune-lighter.vim".text = builtins.readFile ./themes/base16-atelier-dune-lighter.vim;
#       ".config/nvim/colors/base16-gruvbox-dark-medium-custom.vim".text = builtins.readFile ./themes/base16-gruvbox-dark-medium-custom.vim;
#       ".config/nvim/colors/base16-joker.vim".text = builtins.readFile ./themes/base16-joker.vim;
#       ".config/nvim/colors/base16-tokyonight.vim".text = builtins.readFile ./themes/base16-tokyonight.vim;
    };
  };
}
