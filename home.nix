{ pkgs, lib, ... }:

{
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
    sessionPath = [
      "$HOME/.volta/bin"
    ];
    sessionVariables = {
      VOLTA_HOME = "$HOME/.volta";
    };
    packages = with pkgs; [
      _1password-cli
      cloudflared
      coreutils
      delta
      docker
      entr
      eza
      fastfetch
      fd
      fzf
      gitleaks
      htop
      jq
      tree-sitter
      volta
      watch
      yarn-berry # Yarn 4, matching the packageManager pin in the lookout repo
      zoxide
    ];
  };

  programs = {
    home-manager.enable = true;
  };
}
