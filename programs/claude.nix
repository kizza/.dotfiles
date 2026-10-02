{ config, edgePkgs, lib, ... }:

let
  # Mods want Claude Code 2.1.287. Below it one is not loaded at all — quietly, with no error and no
  # hook ever running — which is the first of the two gates `paddckViaMod` below is set against.

  /*
    TEMPORARY. Names the release directly rather than waiting for nixpkgs to pin it.

    The derivation is still nixpkgs' own, and `manifest` is an argument it already exposes — so this
    changes which release is pulled down and nothing whatever about how. It reads three values out
    of what it is given and no others: `version`, and the `binary` and `checksum` of the one
    platform it is building for. Everything else upstream publishes in `manifest.zst.json` — the
    other seven platforms, sizes, build date, SDK compatibility — nixpkgs never looks at, and Nix
    never evaluates an attribute nobody asks for. So this is the whole of it.

    It exists because the wait has two queues, not one: nixpkgs master is on 2.1.286 and
    nixpkgs-unstable behind that on 2.1.283, while upstream has published 2.1.287. Waiting on both
    of them to reach a release that is already out, to run a mod that is already written, is the
    one cost here with nothing on the other side of it.

    To move it to a later release, take the two values from upstream's own file:

        curl -fsSL https://downloads.claude.ai/claude-code-releases/latest
        curl -fsSL https://downloads.claude.ai/claude-code-releases/<version>/manifest.zst.json \
          | jq '{version, darwin: .platforms."darwin-arm64" | {binary, checksum}}'

    TO REMOVE IT, once unstable has caught up. Check with:

        nix flake update nixpkgs-edge
        nix eval --raw "github:nixos/nixpkgs/nixpkgs-unstable#claude-code.version"

    Once that prints 2.1.287 or better, all three of these go together:

      1. delete `pinClaudeToMods` and `claudePackage`, both in this `let`
      2. put the package line back to what it was — the spelling is kept at its call site below
      3. drop `lib` from this file's arguments if nothing else here has taken it up

    `paddckViaMod` stays: it is the gate, not the workaround, and goes later and for a different
    reason. See the note on it below.
  */
  pinClaudeToMods = true;

  # darwin-arm64 alone, because that is the only platform this file is ever evaluated for — the
  # Linux host does not import it. Another platform would fail loudly on a missing attribute rather
  # than quietly build the wrong thing.
  claudePackage =
    if pinClaudeToMods
    then edgePkgs.claude-code.override {
      manifest = {
        version = "2.1.287";
        platforms.darwin-arm64 = {
          binary = "claude.zst";
          checksum = "2701dac04e02acbea7d7584fc35e04adddf6f24021d321e3ba7eb95994edcf96";
        };
      };
    }
    else edgePkgs.claude-code;

  /*
    Which of the two senders tells paddck what this session is doing: the settings hooks below, or
    the `paddck-state` mod under `agentic/mods`. They do the same job and must never both do it —
    two writers racing on one pane option is a row that flickers between two truths.

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

      1. delete this binding, `paddckHook` and `paddckHooks`
      2. drop the two `++ paddckHooks` below, on SessionStart and Stop
      3. delete the whole `// lib.optionalAttrs (!paddckViaMod) { … }` group of seven hook entries
      4. make `env.CLAUDE_CODE_PLUGIN_DIRS` unconditional — it is the only reason `settings` is
         spliced with `//` rather than written as one attrset
      5. delete the `~/.claude/hooks/paddck-agent-state.sh` link: nothing else reads it

    What stays either way: `turn-done.sh` on Stop and herdr's hook on SessionStart, which are not
    paddck's; and `PermissionRequest`, which is the visual notification.
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
    # Edge, or the manifest beside this file while edge is behind the release mods need. When the
    # pin goes, this line goes back to exactly what it was and this comment goes with it:
    #
    #     package = edgePkgs.claude-code; # Use edge packages for latest
    #
    package = claudePackage;
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
      }
      # The seven that exist only to carry paddck's hook, and so the seven that go when the mod has
      # the job. They leave as whole entries rather than as empty matchers: a `Notification` key
      # holding nothing is a question a later reader has to answer.
      // lib.optionalAttrs (!paddckViaMod) {
        # The late one. It arrives six seconds after the question it describes when you are away
        # from the pane and a minute when you are not, and calls a question and a tool waiting to be
        # approved by the same name. The mod reads `tool.check` instead, where the engine decides.
        Notification = [
          {
            matcher = "permission_prompt|idle_prompt|agent_needs_input|elicitation_dialog|elicitation_url_dialog|agent_completed";
            hooks = [ paddckHook ];
          }
        ];

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
