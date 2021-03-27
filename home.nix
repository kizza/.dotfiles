{ pkgs, ... }:

{
  imports = [
    ./fonts.nix
    programs/alacritty
    programs/base16-shell.nix
    programs/bat
    programs/diff-so-fancy.nix
    programs/direnv.nix
    programs/git
    programs/karabiner
    programs/swiftlint.nix
    programs/tmux
    programs/vim
    programs/zsh
  ];

  home = {
    username = builtins.getEnv "USER";
    homeDirectory = builtins.getEnv "HOME";
    packages = with pkgs; [
      coreutils
      entr
      fd
      fzf
      htop
      jq
      ripgrep
      zoxide
      solargraph
      rubocop
    ];

    sessionVariables = {
      HOME_MANAGER_CONFIG = "$HOME/.dotfiles/home.nix";
    };
  };

  programs = {
    home-manager.enable = true;
  };
}
