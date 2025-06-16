{ pkgs, lib, ... }:

let
  isDarwin = builtins.currentSystem == "aarch64-darwin";
in
{
  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
    "1password-cli"
  ];

  imports = [
    ./fonts.nix
    programs/alacritty
    programs/bat
    programs/direnv.nix
    programs/git
    programs/nvim
    programs/ripgrep
    programs/tinted-shell
    programs/tmux
    programs/zsh
  ] ++ (if isDarwin then [
    programs/karabiner
    programs/macvim
  ] else []);

  home = {
    username = builtins.getEnv "USER";
    homeDirectory = builtins.getEnv "HOME";
    stateVersion = "22.05";
    packages = with pkgs; [
      _1password-cli
      cloudflared
      delta
      docker
      entr
      eza
      fd
      fzf
      git-secrets
      htop
      jq
      nodePackages.pnpm
      tree-sitter
      watch
      yarn
      zoxide
    ] ++ (if isDarwin then [
      awscli2
      btop
      cargo
      colima
      coreutils
      overmind
      rustc
      solargraph
    ] else []);

    sessionVariables = {
      HOME_MANAGER_CONFIG = "$HOME/.dotfiles/home.nix";
    };
  };

  programs = {
    home-manager.enable = true;
  };
}
