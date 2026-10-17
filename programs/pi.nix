{ config, edgePkgs, ... }:

{
  # Edge, like claude-code: the locked nixpkgs is a major version behind on pi.
  programs.pi-coding-agent = {
    enable = true;
    package = edgePkgs.pi-coding-agent;

    # The same global instructions Claude Code loads. pi reads the agent directory's `AGENTS.md` (or
    # `CLAUDE.md`), so the one file under `agentic/` serves both; this writes it as `AGENTS.md`.
    context = ./agentic/CLAUDE.md;

    # settings.json is deliberately left to pi. `Ctrl+S` on `/model` and `/thinking` saves the
    # default there, and a store symlink would refuse the write — the opposite of what an agent still
    # being tried out needs. Once the defaults have settled, lift them into `settings` here.
  };

  # pi walks its skills directory recursively and takes any directory holding a `SKILL.md`, so the
  # shared skills and the workflow plugin's sit side by side under it. Claude Code gets the latter as
  # a plugin (`CLAUDE_CODE_PLUGIN_DIRS` in claude.nix); pi has no plugin seam, and does not need one.
  #
  # Recursive, as the claude-code and opencode modules link theirs: a single symlink to the store
  # directory is not a directory to a reader that does not follow links.
  home.file.".pi/agent/skills/shared" = {
    source = ./agentic/skills;
    recursive = true;
  };
  home.file.".pi/agent/skills/workflow" = {
    source = ./agentic/plugins/workflow/skills;
    recursive = true;
  };

  # The extension belongs to paddck: changes to its lifecycle vocabulary reach the next Pi
  # session without a Home Manager switch, just as opencode's adapter does.
  home.file.".pi/agent/extensions/paddck.js".source =
    config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/Code/kizza/paddck/scripts/agents/pi.js";
}
