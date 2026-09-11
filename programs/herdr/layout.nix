{ pkgs }:

# herdr resizes panes incrementally and has no even-layout action, so tmux's absolute
# `resize-pane -x 70%` and `select-layout even-horizontal` have no native equivalent. Both are only
# ratio changes on the tab's split tree, which the socket API exposes as layout.export plus
# layout.set_split_ratio — cheap enough to drive from a keybinding. flake8 runs at build time, so a
# syntax error fails `switch` rather than the keypress.
pkgs.writers.writePython3Bin "herdr-layout" { flakeIgnore = [ "E501" ]; }
  (builtins.readFile ./herdr-layout.py)
