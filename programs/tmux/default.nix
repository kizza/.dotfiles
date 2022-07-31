{ pkgs, ... }:

let
  italics = pkgs.callPackage ./italics.nix {};
in
{
  programs.tmux = {
    enable = true;
    baseIndex = 1;
    escapeTime = 0;
    extraConfig = builtins.readFile ./tmux.conf;
    newSession = true;
    plugins = [];
    terminal = "screen-256color";
  };

  home = {
    file.".terminfo".source = italics;
  };
}
