{ pkgs, lib, ... }:

let
  # The bar's config and plugins colour themselves from $BASE16_COLOR_*_HEX, which tinted-shell only
  # exports into interactive shells — so a bar started by AeroSpace's launchd agent came up unthemed.
  # Sourcing the active theme into the daemon here fixes both: the config and every plugin the daemon
  # later spawns inherit the palette. PATH is set for the same reason — launchd gives us neither the
  # nix profile nor ~/.local/bin, so `aerospace` and `sketchybar` must be put there deliberately.
  startSketchybar = pkgs.writeShellScriptBin "start-sketchybar" ''
    export PATH="${pkgs.aerospace}/bin:${pkgs.sketchybar}/bin:$PATH"

    set -a
    BASE16_SHELL_ENABLE_VARS=true
    themeScript="$HOME/.config/tinted-theming/base16_shell_theme"
    # Discard stdout — the theme script prints terminal escape codes we have no terminal for
    [ -e "$themeScript" ] && . "$themeScript" >/dev/null 2>&1
    set +a

    # Replace any running bar, so a restart is one command rather than kill-then-start
    /usr/bin/pkill -x sketchybar || true
    for _ in 1 2 3 4 5 6 7 8 9 10; do
      /usr/bin/pgrep -x sketchybar >/dev/null 2>&1 || break
      sleep 0.2
    done

    exec sketchybar "$@"
  '';
in
{
  # Aerospace starts the bar, and reaches the script through here — modules can't share a let binding
  options.sketchybar.start = lib.mkOption {
    type = lib.types.package;
    internal = true;
  };

  config = {
    sketchybar.start = startSketchybar;

    programs.sketchybar = {
      enable = true;
      service = {
        enable = false; # Started by aerospace, once its server is up
      };
      config = builtins.readFile ./sketchybarrc.sh;
    };

    home = {
      packages = [startSketchybar]; # Also the supported way to restart the bar by hand

      file = {
        ".config/sketchybar/plugins/aerospace.sh" = {
          source = ./plugins/aerospace.sh;
          executable = true;
        };
        ".config/sketchybar/plugins/app_icons.sh" = {
          source = ./plugins/app_icons.sh;
          executable = true;
        };
      };
    };
  };
}
