{ pkgs, lib, ... }:

{
  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
    "1password-cli"
    "github-copilot-cli"
  ];

  nixpkgs.overlays = [
    (final: prev: {
      # Override Fish to skip tests (they were flakey in home-manager update)
      fish = prev.fish.overrideAttrs (old: {
        doCheck = false;
        cmakeFlags = (old.cmakeFlags or [ ]) ++ [ "-DFISH_BUILD_TESTS=OFF" ];
      });

      # Override neovim to skip tests (error --listen: address already in use: "T162")
      neovim-unwrapped = prev.neovim-unwrapped.overrideAttrs (old: {
        doCheck = false;
      });
    })
  ];

  imports = [
    ./fonts.nix
    programs/bat
    programs/direnv.nix
    programs/git
    programs/nvim
    programs/ripgrep
    programs/tinted-shell
    programs/tmux
    programs/zsh
  ];

  home = {
    stateVersion = "22.05";
    packages = with pkgs; [
      _1password-cli
      cargo
      cloudflared
      delta
      docker
      entr
      eza
      fastfetch
      fd
      fzf
      git-secrets
      htop
      jq
      pnpm
      tree-sitter
      watch
      yarn
      zoxide
    ];
  };

  programs = {
    home-manager.enable = true;
  };
}
