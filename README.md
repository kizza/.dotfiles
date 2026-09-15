# 🏠 dotfiles

A declarative macOS + Linux home environment, built with [Nix](https://nixos.org/) and
[home-manager](https://github.com/nix-community/home-manager). Everything below — shell, editor,
terminal, window manager, keyboard, agents, fonts — is described once here and applied with a single
`switch`.  I have a love/hate relationship with the _readonly_ files home-manager generates from this source.
That said...
- It means I no longer accidentally drift and iterate my dotfiles outside this repo
- I benefit from the curated and aligned infrastructure the nix ecosystem provdies
- I enjoy declarative contexts, as well as learning about nix in general

## Getting started

**1. Install Nix** — [multi-user](https://nixos.org/download/), which is the default on macOS and
needs the flag on Linux

```sh
# macOS
curl --proto '=https' --tlsv1.2 -L https://nixos.org/nix/install | sh

# Linux
curl --proto '=https' --tlsv1.2 -L https://nixos.org/nix/install | sh -s -- --daemon
```

**2. Turn on flakes** — this config is a flake, and the installer doesn't enable them

```sh
echo "experimental-features = nix-command flakes" | sudo tee -a /etc/nix/nix.conf
sudo launchctl kickstart -k system/org.nixos.nix-daemon   # macOS; systemctl restart nix-daemon on Linux
```

**3. Build it**

```sh
./switch
```

Same command on a fresh machine as on a running one — it runs the home-manager CLI out of the flake,
so nothing needs installing first, and the CLI is always the one pinned in `flake.lock`.

It builds the configuration named `$USER@$(hostname)` — see `homeConfigurations` in
[`flake.nix`](flake.nix), which is how one repo serves the laptop, the Linux boxes, and each user on
them. A new machine needs its own entry there first; there's no generic fallback, and Nix will say
so by name if one is missing.

**4. Make zsh the login shell**

```sh
sudo bash -c "echo $(which zsh) >> /etc/shells"
chsh -s $(which zsh) $(whoami)
```

## How it's laid out

```
flake.nix          inputs (nixpkgs, home-manager, …) and one entry per user@host
home.nix           the shared base — imported by every host
fonts.nix          nerd fonts
programs/          one module per tool
bin/               ~35 hand-rolled scripts, put on PATH
theme/             a base16 palette generator (TypeScript), for making new themes
switch / update / clean   the three commands worth remembering
```

A module is either `programs/<name>.nix` when it's self-contained, or `programs/<name>/default.nix`
when it has config files, scripts or assets sitting alongside it.

| Area | Where | Notes |
| --- | --- | --- |
| 🐚 Shell | `programs/zsh` | zsh with vi keybindings; config split into small `*.sh` fragments, composed in `default.nix` |
| ✏️ Editor | `programs/nvim` | Neovim, Lua config, [lazy.nvim](https://github.com/folke/lazy.nvim) for plugins |
| 🖥️ Terminal | `programs/ghostty.nix`, `programs/tmux` | Ghostty is the daily driver; tmux carries the session layer |
| 🪟 Window management | `programs/aerospace.nix`, `programs/jankyborders.nix`, `programs/sketchybar` | Tiling, focus borders that track layout state, and a status bar |
| ⌨️ Keyboard | `programs/karabiner` | Karabiner-Elements remaps |
| 🌿 Git | `programs/git` | Config, aliases, [delta](https://github.com/dandavison/delta), and a global pre-commit hook wired via `core.hooksPath` |
| 🤖 Agents | `programs/agentic`, `programs/claude.nix`, `programs/herdr` | Claude Code settings, global instructions and skills — version-controlled rather than hand-edited |
| 🎨 Theme | `theme/`, `programs/tinted-shell`, `programs/bat` | One base16 palette, rendered out to every tool that wants colours |

`programs/vim`, `programs/macvim` and `programs/alacritty` aren't imported anywhere — they're kept
because Neovim still borrows the vim `ftplugin`, `snippets` and `syntax` files.

## Working on it

Modules everyone gets are imported in [`home.nix`](home.nix). Modules only one machine wants are
imported in that host's block in [`flake.nix`](flake.nix). So adding a tool is usually:

1. Write `programs/<tool>.nix` (or `programs/<tool>/default.nix`).
2. Add it to the `imports` in `home.nix`, or to the host that wants it in `flake.nix`.
3. `./switch`.

Two things to know before editing:

- **Generated files are read-only.** Anything home-manager writes lands as a symlink into the Nix
  store — `~/.claude/settings.json`, `~/.gitconfig` and friends. Edit the source here and `switch`;
  editing the live file won't work.
- **Some packages track edge.** `nixpkgs-edge` is a second nixpkgs input for things worth having
  fresh (Claude Code, herdr). Those modules take `edgePkgs` instead of `pkgs`.

```sh
./update          # bump every input
./update --edge   # bump just the edge pin
./switch          # rebuild and apply
```

## 🎨 Themes

Themes live in [base16-studio](https://github.com/kizza/base16-studio) — a separate repo holding the
[base16](https://github.com/chriskempson/base16) palettes and the tooling to switch between them.
`theme` picks one interactively; `dark`, `light` and `brown` jump straight to a favourite. The choice
is written into `~/.config/tinted-theming`, where
[tinted-shell](https://github.com/tinted-theming/tinted-shell) renders it out as a shell theme and
exports the sixteen colours as environment variables.

Everything downstream reads from there, so the terminal, tmux, bat, sketchybar and the editor all
recolour together.

[`theme/`](theme/README.md) is where a palette gets built in the first place — from a
[terminal.sexy](https://terminal.sexy/) export, or by pulling the colours out of an image on the
clipboard.

## Maintenance

```sh
./clean
```

Collects garbage and drops past generations, then deduplicates identical store paths. It offers the
docker prune at the end rather than just doing it — that one takes volumes with it.

## Further reading

- [Nix](https://nixos.org/) — the package manager and language
- [home-manager](https://nix-community.github.io/home-manager/) — user environments as modules
  ([options reference](https://nix-community.github.io/home-manager/options.xhtml))
- [Nix flakes](https://nixos.wiki/wiki/Flakes) — pinned inputs, reproducible builds
- [base16](https://github.com/chriskempson/base16) — the palette scheme everything here is themed on
