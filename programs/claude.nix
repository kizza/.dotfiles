{ pkgs, edgePkgs, ... }:

{
  home.packages = with pkgs; [
    claude-agent-acp
  ];

  programs.claude-code = {
    enable = true;
    package = edgePkgs.claude-code; # Use edge packages for latest
    skills = ./agentic/skills;

    # Global instructions loaded in every project (~/.claude/CLAUDE.md)
    context = ./agentic/CLAUDE.md;

    # ~/.claude/settings.json — version-controlled here instead of hand-edited.
    # Note: this becomes a read-only store symlink, so future permission/hook
    # changes go through Nix + `switch`, not the live file.
    settings = {
      model = "opus[1m]";
      theme = "auto";

      permissions.allow = [
        "Bash(~/.dotfiles/bin/piper_say *)"
      ];

      statusLine = {
        type = "command";
        command = "~/.claude/statusline.sh";
      };

      hooks = {
        # Speak nothing generic here — the voice-intent rule makes Claude speak the
        # specific request. This visual notification is the can't-miss fallback.
        PermissionRequest = [
          {
            hooks = [
              {
                type = "command";
                command = "osascript -e 'display notification \"Claude needs permissions\" with title \"Claude Code\"'";
                async = true;
              }
            ];
          }
        ];

        SessionStart = [
          {
            matcher = "*";
            hooks = [
              {
                type = "command";
                command = "bash '/Users/keiran/.claude/hooks/herdr-agent-state.sh' session";
                timeout = 10;
              }
            ];
          }
        ];

        Stop = [
          {
            hooks = [
              {
                type = "command";
                command = "~/.dotfiles/bin/piper_say 'claude done'";
                async = true;
              }
              {
                type = "command";
                command = "osascript -e 'display notification \"Claude is done\" with title \"Claude Code\"'";
                async = true;
              }
            ];
          }
        ];
      };
    };
  };
}
