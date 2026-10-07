{ config, edgePkgs, lib, ... }:

let
  # Mods want Claude Code 2.1.287. Below it one is not loaded at all — quietly, with no error and no
  # hook ever running — which is the first of the two gates `paddckViaMod` below is set against.
  # The package was pinned to a named release while nixpkgs lagged that version; unstable has since
  # caught up, so the pin is gone. To hydrate it, take `pinClaudeToMods` and `claudePackage` out of
  # 3eea9cd5c5a5 — the comment there carries the recipe for naming a later release.

  /*
    Which of the two senders tells paddck what this session is doing: the settings hooks below, or
    the `paddck-state` mod under `agentic/mods`. They do the same job and must never both do it —
    two writers racing on one pane option is a row that flickers between two truths.

    With one exception, and it is a real one rather than a hedge: `Notification` stays either way.
    A standing permission prompt is the one moment a mod cannot observe at all — `tool.check`
    resolves before the mode settles it, and `tool.call` spans the prompt and the tool's own run
    together — so there is nothing for the mod to race with. The entry carries its own account of
    this where it is declared.

    Set by hand, and it has to be. The obvious move is to derive it from the package version, and
    that is wrong: the version is necessary and not sufficient. Whether a mod loads is also decided
    by a switch Anthropic serves per process — `the rollout switch served off` in the debug log —
    which no local setting overrides and which nothing here can see. Measured on 2.1.287 over
    thirteen runs it served off three times, so a config that trusts the version alone would take
    the hooks away and leave roughly one session in five with no sender at all.

    Nor can the mod cover for it, from either side. Answering `classic.SessionEnd` without calling
    `next` does not stop the settings hook behind it running — tested, three runs, it ran every
    time. And the mod cannot read those events anyway: the built-in guard bypasses `classic.*` for
    a mod at user tier, so it never sees them.

    So the two senders cannot be made to hand over automatically, and the flag is the honest shape:
    one word, set deliberately, in the knowledge of what it costs.

    WHAT IT COSTS, with this `true`. Roughly one session in five starts with no sender at all, and
    says nothing about it: paddck simply never hears from that pane, so its row holds whatever it
    last knew. The switch is rolled afresh per process, so the cure is to restart the session —
    `claude --resume` picks the conversation up and rolls again, and the mod reads identity off
    `$.session` on each message rather than caching it, so the pane is corrected by the first turn
    after it does load.

    HOW TO TELL. The row going quiet is the symptom; this is the confirmation:

        claude -p "hi" --debug-file /tmp/d.log
        grep "hooks module paddck-state" /tmp/d.log

    `loaded` and the events it hooks, or `not loaded:` and `the rollout switch served off`.
    `claude plugin test` is not the check — it reports that mods can load without asking the
    server, so it says yes while the switch is serving no.

    TO REMOVE THE FALLBACK, once the mod has run for a while and is trusted. This is a later job
    than removing the pin and a different judgement: that one waits on nixpkgs, this one waits on
    you. Until then the hooks are worth their keep — one line back to a sender that works.

      1. delete this binding and `paddckHooks` — but *not* `paddckHook`, which `Notification` keeps
      2. drop the two `++ paddckHooks` below, on SessionStart and Stop
      3. delete the whole `// lib.optionalAttrs (!paddckViaMod) { … }` group of six hook entries,
         and settle `Notification`'s matcher to the narrow spelling
      4. make `env.CLAUDE_CODE_PLUGIN_DIRS` unconditional — it is the only reason `settings` is
         spliced with `//` rather than written as one attrset
      5. keep the `~/.claude/hooks/paddck-agent-state.sh` link — `Notification` is still reaching
         paddck through it

    What stays either way: paddck's own `Notification`, above; `turn-done.sh` on Stop and herdr's
    hook on SessionStart, which are not paddck's; and `PermissionRequest`, the visual notification.
  */
  paddckViaMod = true;

  # The one entry seven of the hooks below exist to carry. Named once so that removing it is one
  # deletion rather than seven, and so the entries read as what they are: a list of the moments
  # paddck has to be told about.
  paddckHook = {
    type = "command";
    command = "/Users/keiran/.claude/hooks/paddck-agent-state.sh";
    timeout = 10;
  };

  # Nothing at all once the mod has the job. Two entries keep a hook of their own either way and so
  # append this rather than being dropped: SessionStart has herdr's, Stop has turn-done.sh.
  paddckHooks = lib.optionals (!paddckViaMod) [ paddckHook ];
in

{
  # Use edge nix to align with claude
  home.packages = with edgePkgs; [
    claude-agent-acp
  ];

  # Linked to the checkout rather than copied out of it. The hook is paddck's own file and changes
  # with paddck; a copy here was a second spelling that went stale the first time the script grew an
  # argument, and nothing said so — a hook that fails is a hook that exits 0.
  #
  # Nothing but the settings hooks below reads this path. opencode's plugin and the mod both resolve
  # `scripts/agents/state.sh` out of `PADDCK_ROOT` themselves, so this goes when they do.
  home.file.".claude/hooks/paddck-agent-state.sh".source =
    config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/Code/kizza/paddck/scripts/agents/state.sh";

  # The remarks skills live in the plugin they document — `remarks.nvim` is the source of truth for
  # both, and these are linked out of the store so that editing one there is what the next session
  # loads. Kept here rather than under `agentic/skills` because a copy in this repo is a second
  # spelling of a file that is already versioned somewhere else, and the two drifted.
  home.file.".claude/skills/remarks".source =
    config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/Code/kizza/nvim/remarks.nvim/skills/remarks";

  home.file.".claude/skills/remarks-retro".source =
    config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/Code/kizza/nvim/remarks.nvim/skills/remarks-retro";

  # Ours rather than paddck's: what a finished turn should announce is a preference, not a fact
  # about an agent. It is a file rather than an inline command because it reads the payload before
  # it says anything, and a shell script that quotes JSON is not something to write through two
  # layers of Nix escaping.
  home.file.".claude/hooks/turn-done.sh" = {
    source = ./agentic/hooks/turn-done.sh;
    executable = true;
  };

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

      # No `model` — new sessions take whatever default Claude Code ships, which is the recommended
      # one. To pin a model again, lift the line out of 835583ae090a.

      # Compact at a fixed 400k of context rather than letting Claude pick the window ("auto").
      # Token count, not the /autocompact shorthand — 400 there means 400k here.
      autoCompactWindow = 400000;

      # Keep Claude out of the commit trailer — no "Co-Authored-By: Claude" on
      # commits it writes.
      includeCoAuthoredBy = false;

      enabledPlugins = {
        "i-have-adhd@i-have-adhd" = true;
        "code-review-plugin@the-lookout-way" = true;
      };


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

        # Herdr's either way; paddck's joins it only while the hooks have the job. Nothing the mod
        # does depends on this entry — it cannot see `classic.*` at all — so what is left here is
        # herdr's own business.
        SessionStart = [
          {
            matcher = "*";
            hooks = [
              {
                type = "command";
                command = "bash '/Users/keiran/.claude/hooks/herdr-agent-state.sh' session";
                timeout = 10;
              }
            ] ++ paddckHooks;
          }
        ];

        # turn-done.sh stays whichever sender is live: what a finished turn should announce is a
        # preference, not a fact about an agent, and nothing about it moves into the mod.
        #
        # It is also the last reader of `Stop`'s `background_tasks`. The mod cannot see that payload
        # and counts subagents itself, which misses a backgrounded Bash command — see the mod's
        # `backgroundWork` for what that costs.
        Stop = [
          {
            hooks = [
              # Spoken and on screen, named after the branch rather than the agent — and silent
              # while the turn has left subagents running. See the script for both halves.
              {type = "command"; command = "/Users/keiran/.claude/hooks/turn-done.sh"; async = true;}
            ] ++ paddckHooks;
          }
        ];

        /*
          The one moment paddck cannot learn from inside the session, and so the one hook that stays
          whichever sender has the job: a permission prompt that is really standing, waiting on a
          human.

          The mod used to answer this off `tool.check` and it was wrong to. `ask` there does not
          mean a prompt was shown — it means the call went to *the mode's decider*, which under auto
          mode is a classifier that answers in a second and shows nobody anything. So every tool
          call turned the pane amber for as long as it took to run. Nor can the reading be repaired
          where it was made: `tool.check` resolves before the mode settles, and `tool.call`'s
          `next(e)` spans the prompt and the tool's own run as one, so a mod has no moment that
          means *the human answered*.

          This event has both, at the cost of arriving late — six seconds after the fact when you
          are away from the pane, a minute when you are not. Late and true beats immediate and
          wrong, and the mod clears it on the far side; see `register.js` on `promptFloorMilliseconds`.

          Narrowed to the types that mean a human is wanted *now*. `idle_prompt` and
          `agent_completed` are left out deliberately: both describe a turn that has ended, the mod
          already says so from `turn.complete`, and it says it better — `idle_prompt` reaches an
          agent that stopped with subagents still running, which is the one state that is not idle
          at all.
        */
        Notification = [
          {
            # Wider without the mod, because then there is nothing better saying a turn has ended:
            # `idle_prompt` and `agent_completed` go back to carrying their own weight.
            matcher =
              if paddckViaMod then
                "permission_prompt|agent_needs_input|elicitation_dialog|elicitation_url_dialog"
              else
                "permission_prompt|idle_prompt|agent_needs_input|elicitation_dialog|elicitation_url_dialog|agent_completed";
            hooks = [ paddckHook ];
          }
        ];
      }
      # The six that exist only to carry paddck's hook, and so the six that go when the mod has the
      # job. They leave as whole entries rather than as empty matchers: a `PreToolUse` key holding
      # nothing is a question a later reader has to answer.
      //
      lib.optionalAttrs (!paddckViaMod) {
        # The mod has `turn.start`, which is the same moment and raises nothing for a subagent.
        UserPromptSubmit = [ { hooks = [ paddckHook ]; } ];

        # A question is a tool call, and the only way paddck hears about one as it happens.
        PreToolUse = [ { matcher = "AskUserQuestion"; hooks = [ paddckHook ]; } ];

        # Answered, and escaped out of. The pane wants the turn back either way — which the mod gets
        # from one `tool.call` hook that waits on the call rather than from two events.
        PostToolUse = [ { matcher = "AskUserQuestion"; hooks = [ paddckHook ]; } ];
        PostToolUseFailure = [ { matcher = "AskUserQuestion"; hooks = [ paddckHook ]; } ];

        # The other end of a background subagent, and the entry the mod most earns. This fires for a
        # subagent the turn *waited* for as well, where the payload looks identical and the turn is
        # still going; a shell script has nothing to tell the two apart with, so paddck reads back
        # what the pane already says, over tmux, every time. The mod remembers instead.
        SubagentStop = [ { hooks = [ paddckHook ]; } ];

        SessionEnd = [ { hooks = [ paddckHook ]; } ];
      };
    }
    # Loaded from the checkout rather than installed from a marketplace, for the same reason the
    # paddck hook is a symlink: what you edit is what the next session loads, with no `switch` and
    # no version to bump between writing a change and running it. Spliced in rather than declared
    # above so that settings.json keeps no empty `env` while the hooks still have the job.
    // lib.optionalAttrs paddckViaMod {
      env.CLAUDE_CODE_PLUGIN_DIRS = "/Users/keiran/.dotfiles/programs/agentic/mods/paddck-state";
    };
  };
}
