{ pkgs, ... }:

{
  imports = [
    ./fonts.nix
    programs/alacritty
    programs/base16-shell
    programs/bat
    programs/direnv.nix
    programs/git
    programs/karabiner
    programs/macvim
    programs/nvim
    programs/ripgrep
    programs/tmux
    # programs/vim 
    programs/zsh
  ];

  home = {
    username = builtins.getEnv "USER";
    homeDirectory = builtins.getEnv "HOME";
    stateVersion = "22.05";
    packages = with pkgs; [
      cargo
      colima
      coreutils
      docker
      entr
      eza
      delta
      fd
      fzf
      git-secrets
      htop
      jq
      overmind
      zoxide
      solargraph
      tree-sitter
      watch
      yarn
    ];

    sessionVariables = {
      HOME_MANAGER_CONFIG = "$HOME/.dotfiles/home.nix";
    };
  };

  programs = {
    home-manager.enable = true;
  };
}
