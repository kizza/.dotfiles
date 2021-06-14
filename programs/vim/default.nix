{ pkgs, ... }:

let
  plugins = pkgs.vimPlugins // pkgs.callPackage ./custom-plugins.nix {};
in
{
  imports = [
    ./snippets.nix
    ./syntax.nix
  ];

  home = {
    file.".config/nvim/init.vim".text = ''
      set runtimepath^=~/.vim runtimepath+=~/.vim/after
      let &packpath=&runtimepath
      source ~/.vimrc
    '';

    file.".config/nvim/coc-settings.json".text = builtins.readFile ./misc/coc-settings.json;
    file.".vim/coc-settings.json".text = builtins.readFile ./misc/coc-settings.json;

    file.".vimrc".text = ''
      ${builtins.readFile ./begin.vim}

      ${builtins.readFile ./plugins/actionmenu.vim}
      ${builtins.readFile ./plugins/ale.vim}
      ${builtins.readFile ./plugins/buffers.vim}
      ${builtins.readFile ./plugins/coc.vim}
      ${builtins.readFile ./plugins/fzf.vim}
      ${builtins.readFile ./plugins/gitgutter.vim}
      ${builtins.readFile ./plugins/javascript.vim}
      ${builtins.readFile ./plugins/nerdtree.vim}
      ${builtins.readFile ./plugins/vim-better-whitespace.vim}
      ${builtins.readFile ./plugins/vim-airline.vim}
      ${builtins.readFile ./plugins/vim-indent-guides.vim}
      ${builtins.readFile ./plugins/vanilla.vim}
      ${builtins.readFile ./end.vim}

      ${builtins.readFile ./config/colours.vim}
      ${builtins.readFile ./config/globals.vim}
      ${builtins.readFile ./config/mappings.vim}
      ${builtins.readFile ./config/search.vim}
      ${builtins.readFile ./config/splits.vim}
      ${builtins.readFile ./config/undo.vim}
      ${builtins.readFile ./config/wildmenu.vim}
    '';
  };

  programs.neovim = {
    enable = true;
  };
}
