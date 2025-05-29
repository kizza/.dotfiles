{ pkgs, ... }:

{
  # Use latest neovim
  # https://github.com/nix-community/neovim-nightly-overlay
  # nixpkgs.overlays = [
  #   (import (builtins.fetchTarball {
  #     url = https://github.com/nix-community/neovim-nightly-overlay/archive/master.tar.gz;
  #   }))
  # ];

  home = {
    # Lua config
    file.".config/nvim/lua" = { source = ./lua; recursive = true; };
    file.".config/nvim/init.lua".text = builtins.readFile ./init.lua;

    # Legacy config
    file.".config/nvim/config" = { source = ./config; recursive = true; };

    # Other vim files
    file.".config/nvim/ftplugin/".source = ../vim/ftplugin;
    file.".config/nvim/snippets/".source = ../vim/snippets;
    file.".config/nvim/syntax/".source = ../vim/syntax;

    # LSP config
    file.".config/solargraph/config.yml".text = builtins.readFile ./lua/plugins/lsp/solargraph.yaml;

    # Tree-sitter config
    /* file.".config/nvim/parser/html.so".source = "${pkgs.vimPlugins.nvim-treesitter.builtGrammars.html}/parser"; */
    # file.".config/nvim/parser/ruby.so".source = "${pkgs.vimPlugins.nvim-treesitter.builtGrammars.tree-sitter-ruby}/parser";
    # file.".config/nvim/parser/javascript.so".source = "${pkgs.vimPlugins.nvim-treesitter.builtGrammars.tree-sitter-javascript}/parser";
    file.".config/nvim/after/queries/ruby/highlights.scm".text = builtins.readFile ../vim/after/queries/ruby/highlights.scm;
    file.".config/nvim/after/queries/git_rebase/highlights.scm".text = builtins.readFile ../vim/after/queries/git_rebase/highlights.scm;
  };

  programs.neovim = {
    enable = true;
  };
}
