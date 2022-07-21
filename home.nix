{ pkgs, ... }:

{
  imports = [
    ./fonts.nix
    programs/alacritty
    programs/base16-shell.nix
    programs/bat
    programs/direnv.nix
    programs/git
    programs/karabiner
    programs/ripgrep
    programs/swiftlint.nix
    programs/tmux
    programs/vim
    programs/zsh
  ];

  home = {
    username = builtins.getEnv "USER";
    homeDirectory = builtins.getEnv "HOME";
    stateVersion = "20.09";
    packages = with pkgs; [
      coreutils
      entr
      exa
      delta
      fd
      fzf
      htop
      jq
      zoxide
      solargraph
      tree-sitter
      watchman
      watch
    ];

    sessionVariables = {
      HOME_MANAGER_CONFIG = "$HOME/.dotfiles/home.nix";
    };
  };

  programs = {
    home-manager.enable = true;
  };
}
