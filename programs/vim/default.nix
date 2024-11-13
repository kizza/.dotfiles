{ pkgs, ... }:

let
  plugins = pkgs.vimPlugins // pkgs.callPackage ./plugins/sources.nix {};
in
{
  imports = [
    plugins/coc
  ];

  home = {
    # <Plug>s
    file.".vim/plugs.vim".text = ''
      ${builtins.readFile ./plugins/standard.vim}
      ${builtins.readFile ./plugins/actionmenu.vim}
      ${builtins.readFile ./plugins/ale.vim}
      ${builtins.readFile ./plugins/buffers.vim}
      ${builtins.readFile ./plugins/fzf.vim}
      ${builtins.readFile ./plugins/gitgutter.vim}
      ${builtins.readFile ./plugins/javascript.vim}
      ${builtins.readFile ./plugins/nerdtree.vim}
      ${builtins.readFile ./plugins/ruby.vim}
      ${builtins.readFile ./plugins/vim-airline.vim}
      ${builtins.readFile ./plugins/dev.vim}
    '';

    # .vimrc
      # ${lua_plugins}
    file.".vimrc".text = ''
      ${builtins.readFile ./config/plug.vim}
      ${builtins.readFile ./config/colours.vim}
      ${builtins.readFile ./config/globals.vim}
      ${builtins.readFile ./config/mappings.vim}
      ${builtins.readFile ./config/search.vim}
      ${builtins.readFile ./config/splits.vim}
      ${builtins.readFile ./config/undo.vim}
      ${builtins.readFile ./config/wildmenu.vim}
    '';

    # Other vim files
    file.".vim/ftplugin/".source = ./ftplugin;
    file.".vim/snippets/".source = ./snippets;
    file.".vim/syntax/".source = ./syntax;

    /* # Tree-sitter config */
    /* file.".config/nvim/parser/ruby.so".source = "${pkgs.tree-sitter.builtGrammars.tree-sitter-ruby}/parser"; */
    /* file.".config/nvim/parser/javascript.so".source = "${pkgs.tree-sitter.builtGrammars.tree-sitter-javascript}/parser"; */
    /* file.".config/nvim/after/queries/ruby/highlights.scm".text = builtins.readFile ./after/queries/ruby/highlights.scm; */
  };

  programs.vim = {
    enable = true;
    # plugins = (with pkgs.vimPlugins; [
    #   pkgs.nvim-treesitter-full
    # ]);
    /* extraConfig = '' */
    /*   set runtimepath^=~/.vim runtimepath+=~/.vim/after */
    /*   let &packpath=&runtimepath */
    /*   source ~/.vimrc */
    /* ''; */
  };
}
