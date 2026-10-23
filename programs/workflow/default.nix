{ config, pkgs, ... }:

# `workflow-state`: the deterministic half of the workflow manager's standup. A launchd timer gathers what
# the manager would read — pull requests, review requests, cards, worktrees, sessions, annotations, remarks —
# into ~/.config/workflow/state.json every five minutes, and only when something changed does it notify
# Keiran and wake the manager session, through a one-shot Claude that sends it the message. A quiet day
# costs no tokens. See state.py for the graph and the diff, and the `workflow:manager` skill for the standup.

let
  logFile = "${config.home.homeDirectory}/Library/Logs/workflow-state.log";

  workflow-state = pkgs.writeShellApplication {
    name = "workflow-state";
    runtimeInputs = [ pkgs.python312 pkgs.gh pkgs.git pkgs.tmux ];
    text = ''
      # launchd's PATH has none of these: basecamp and claude from the profile, remarks from the dotfiles
      export PATH="$HOME/.nix-profile/bin:$HOME/.dotfiles/bin:$HOME/.local/bin:$PATH"
      exec python3 ${./state.py} "$@"
    '';
  };
in
{
  home.packages = [ workflow-state ];

  launchd.agents.workflow-state = {
    enable = true;
    config = {
      ProgramArguments = [ "${workflow-state}/bin/workflow-state" "tick" ];
      StartInterval = 300;
      RunAtLoad = true;
      StandardOutPath = logFile;
      StandardErrorPath = logFile;
    };
  };
}
