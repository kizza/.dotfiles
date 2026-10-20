{ pkgs, ... }:

let
  italics = pkgs.callPackage ./terminfo.nix {};
  resumeClaudePanes = pkgs.writeShellScript "resume-claude-panes" (builtins.readFile ./resume-claude-panes.sh);
in
{
  programs.tmux = {
    enable = true;
    baseIndex = 1;
    escapeTime = 0;
    extraConfig = let
      shellPackage = pkgs.zsh;
      defaultCommand = if pkgs.stdenv.hostPlatform.isDarwin then
        "exec ${pkgs.reattach-to-user-namespace}/bin/reattach-to-user-namespace -l ${shellPackage}/bin/zsh"
      else
        "exec ${shellPackage}/bin/zsh";
    in ''
      set-option -g default-command '${defaultCommand}'

      ${builtins.readFile ./tmux.conf}

      # Resurrect and continuum load here rather than through `plugins`, which home-manager writes before this
      # config: continuum autosaves from `status-right`, so it has to load after the theme sets that.
      set -g @resurrect-capture-pane-contents 'on'
      set -g @resurrect-processes '"~claude --resume"' # only panes the hook gave a session to resume
      set -g @resurrect-hook-post-save-layout '${resumeClaudePanes}'
      set -g @continuum-restore 'on'
      run-shell ${pkgs.tmuxPlugins.resurrect.rtp}
      run-shell ${pkgs.tmuxPlugins.continuum.rtp}
    '';
    newSession = false; # writes `new-session -A -s 0` which will always look for a session 0
    plugins = [];
    terminal = "screen-256color";
  };

  home = {
    file.".terminfo".source = italics;
  };
}
