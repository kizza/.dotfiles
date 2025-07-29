{ pkgs, ... }:

{
  programs.sketchybar = {
    enable = true;
    service = {
      enable = false; # Started by aerospace
    };
    config = builtins.readFile ./sketchybarrc.sh;
  };
  home = {
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
}
