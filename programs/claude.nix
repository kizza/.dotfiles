{ edgePkgs, ... }:

{
  # Use edge nix to align with claude
  home.packages = with edgePkgs; [
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
      theme = "auto";

      # Default model for new sessions
      model = "claude-opus-5[1m]";

      # Keep Claude out of the commit trailer — no "Co-Authored-By: Claude" on
      # commits it writes.
      includeCoAuthoredBy = false;

      permissions = {
        # Auto mode: a classifier judges each action against allow/soft_deny/hard_deny rulesets
        # rather than matching globs, so actions no explicit rule covers can proceed without a
        # prompt. Not a bypass — unlike `bypassPermissions` it needs no
        # `allowDangerouslySkipPermissions`. Inspect with `claude auto-mode config`.
        #
        # Must live in USER settings: repo-level `.claude/settings.json` cannot grant `auto`, and a
        # repo-level value is ignored while still shadowing this one. Custom rules would go in an
        # `autoMode` section here — note `claude auto-mode reset` cannot remove them from a
        # read-only store symlink.
        defaultMode = "auto";

        # Bare executable name (piper_say is on PATH) — a tilde-path executable
        # like ~/.dotfiles/bin/piper_say does NOT match Claude Code's Bash parser.
        # Explicit allows still earn their place under auto mode: they skip classifier latency.
        allow = [
          "Bash(piper_say *)"
        ];
      };

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
              # Speak the branch's last segment, not "claude" — with several worktree agents
              # running at once, an anonymous "claude done" says nothing about which finished.
              # `billing/duplicate-invoice-lines` speaks as "duplicate-invoice-lines done".
              # Falls back to the directory name when detached or outside a repo.
              {
                type = "command";
                command = "sh -c 'cd \"$CLAUDE_PROJECT_DIR\" 2>/dev/null; n=$(git branch --show-current 2>/dev/null | sed \"s|.*/||\"); [ -n \"$n\" ] || n=$(basename \"$PWD\"); ~/.dotfiles/bin/piper_say \"$n done\"'";
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
