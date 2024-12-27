{ pkgs, ... }:

let
  italics = pkgs.callPackage ./italics.nix {};
in
{
  programs.tmux = {
    enable = true;
    baseIndex = 1;
    escapeTime = 0;
    extraConfig = let
      shellPackage = pkgs.zsh;
      defaultCommand = if pkgs.stdenv.isDarwin then
        "exec ${pkgs.reattach-to-user-namespace}/bin/reattach-to-user-namespace -l ${shellPackage}/bin/zsh"
      else
        "exec ${shellPackage}/bin/zsh";
    in ''
      set-option -g default-command '${defaultCommand}'

      ${builtins.readFile ./tmux.conf}
    '';
    newSession = true;
    plugins = [];
    terminal = "screen-256color";
  };

  home = {
    file.".terminfo".source = italics;
  };
}
