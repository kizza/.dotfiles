{ config, pkgs, ... }:

{
  programs = {
    ghostty = {
      enable = true;
      package = config.lib.nixGL.wrap pkgs.ghostty;
      settings = {
        font-family = "Maple Mono NF";
        font-size = 13;
        font-thicken = true;
        adjust-cell-height = "37%";
        adjust-cursor-height = "37%";
        bold-is-bright = true;
        adjust-underline-position = 4;
        background-opacity = 0.92;
        background-blur = true;
        keybind = [
          "super+c=copy_to_clipboard"
          "super+v=paste_from_clipboard"
          "global:super+grave_accent=toggle_quick_terminal"
          "ctrl+d=unbind"
          "super+shift+left_bracket=text:\x02p"
          "super+shift+right_bracket=text:\x02n"
        ];
      };
    };
  };
}
