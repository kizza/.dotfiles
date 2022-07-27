{ pkgs, ... }:

let
  plugins = pkgs.vimPlugins // pkgs.callPackage ./custom-plugins.nix {};
in
{
  home = {
    file.".vim/ftplugin/".source = ./ftplugin;
    file.".vim/snippets/".source = ./snippets;
    file.".vim/syntax/".source = ./syntax;

    file.".config/nvim/parser/ruby.so".source = "${pkgs.tree-sitter.builtGrammars.tree-sitter-ruby}/parser";
    file.".config/nvim/after/queries/ruby/highlights.scm".text = builtins.readFile ./after/queries/ruby/highlights.scm;

    file.".config/nvim/coc-settings.json".text = builtins.readFile ./misc/coc-settings.json;
    file.".vim/coc-settings.json".text = builtins.readFile ./misc/coc-settings.json;

    file.".vimrc".text = ''
      ${builtins.readFile ./begin.vim}

      ${builtins.readFile ./plugins/actionmenu.vim}
      ${builtins.readFile ./plugins/ale.vim}
      ${builtins.readFile ./plugins/buffers.vim}
      ${builtins.readFile ./plugins/dev.vim}
      ${builtins.readFile ./plugins/coc.vim}
      ${builtins.readFile ./plugins/fzf.vim}
      ${builtins.readFile ./plugins/gitgutter.vim}
      ${builtins.readFile ./plugins/javascript.vim}
      ${builtins.readFile ./plugins/nerdtree.vim}
      ${builtins.readFile ./plugins/ruby.vim}
      ${builtins.readFile ./plugins/vim-argwrap.vim}
      ${builtins.readFile ./plugins/vim-better-whitespace.vim}
      ${builtins.readFile ./plugins/vim-airline.vim}
      ${builtins.readFile ./plugins/vim-indent-guides.vim}
      ${builtins.readFile ./plugins/vanilla.vim}
      ${builtins.readFile ./plugins/dev.vim}
      ${builtins.readFile ./end.vim}

      ${builtins.readFile ./config/lua.vim}

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
    extraConfig = ''
      set runtimepath^=~/.vim runtimepath+=~/.vim/after
      let &packpath=&runtimepath
      source ~/.vimrc
    '';
  };
}
