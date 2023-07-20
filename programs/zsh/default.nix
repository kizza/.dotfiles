{ pkgs, ... }:

{
  # home = {
  #   file.".config/oh-my-zsh/themes/kizza.zsh-theme".text = builtins.readFile ./kizza.zsh-theme;
  # };

  programs.zsh = {
    enable = true;
    defaultKeymap = "viins";
    dotDir = ".config/zsh";
    enableAutosuggestions = true;
    enableSyntaxHighlighting = true;
    initExtra = ''
        ${builtins.readFile ./base-16.sh}
        ${builtins.readFile ./brew.sh}
        ${builtins.readFile ./direnv.sh}
        ${builtins.readFile ./docker.sh}
        ${builtins.readFile ./env.sh}
        ${builtins.readFile ./fzf.sh}
        ${builtins.readFile ./keybindings.sh}
        ${builtins.readFile ./nix.sh}
        ${builtins.readFile ./nvm.sh}
        ${builtins.readFile ./path.sh}
        ${builtins.readFile ./prompt.sh}
        ${builtins.readFile ./ripgrep.sh}
        ${builtins.readFile ./theme.sh}
        ${builtins.readFile ./tmux.sh}
        ${builtins.readFile ./zoxide.sh}
      '';

    envExtra = ''
        ${builtins.readFile ./alias.sh}
        ${builtins.readFile ./git.sh}
        ${builtins.readFile ./helpers.sh}
      '';

    history = {
      expireDuplicatesFirst = true;
      ignoreDups = true;
      ignoreSpace = true;
      share = true;
    };

    shellAliases = {
      reload = ". ~/.config/zsh/.zshrc";
      ls = "ls --color";
      # v = "nvim";
      foo = "cat";
    };

    plugins = [
      {
        name = "zsh-history-substring-search";
        src = pkgs.fetchFromGitHub {
          owner = "zsh-users";
          repo = "zsh-history-substring-search";
          rev = "0f80b8eb3368b46e5e573c1d91ae69eb095db3fb";
          sha256 = "0y8va5kc2ram38hbk2cibkk64ffrabfv1sh4xm7pjspsba9n5p1y";
        };
      }
    ];
  };
}
