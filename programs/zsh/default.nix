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
    initExtra = ''
        ${builtins.readFile ./base-16.sh}
        ${builtins.readFile ./direnv.sh}
        ${builtins.readFile ./docker.sh}
        ${builtins.readFile ./env.sh}
        ${builtins.readFile ./fzf.sh}
        ${builtins.readFile ./helpers.sh}
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
      '';

    history = {
      ignoreDups = true;
      share = true;
    };

    shellAliases = {
      reload = ". ~/.config/zsh/.zshrc";
      # v = "nvim";
      foo = "cat";
    };

    plugins = [
      {
        name = "zsh-syntax-highlighting";
        src = pkgs.fetchFromGitHub {
          owner = "zsh-users";
          repo = "zsh-syntax-highlighting";
          rev = "1715f39a4680a27abd57fc30c98a95fdf191be45";
          sha256 = "1kpxima0fnypl7fak4snxnf6nj36nvp1gqwpx1ailyrgxa8641j0";
        };
      }
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
