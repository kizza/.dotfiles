{ config, pkgs, lib, ... }:

{
  wayland.windowManager.hyprland = {
    enable = true;
    configType = "lua";

    package = config.lib.nixGL.wrap pkgs.hyprland;

    settings = {
      env = [
        "PATH,${config.home.profileDirectory}/bin:/run/current-system/sw/bin:/usr/bin"
      ];

      monitor = ",preferred,auto,1.6";

      exec-once = [
        "hyprpaper"
        "waybar"
      ];

      input = {
        kb_layout = "au";
      };

      general = {
        gaps_in = 5;
        gaps_out = 10;
        border_size = 3;

        "col.active_border" = lib.mkForce "rgba(ff7FBBB3)"; # Violet
        # "col.active_border" = lib.mkForce "rgba(7FBBB3ff)"; # Aqua
      };

      decoration = {
        rounding = 8;

        active_opacity = 1.0;
        inactive_opacity = 0.8;

        blur = {
          enabled = false;
        };
      };

      animations = {
        enabled = true;
      };

      bind = [
        "CTRL,SPACE,exec,rofi -show drun"
        "SUPER,RETURN,exec,nixGLIntel ghostty"
        "SUPER SHIFT,B,exec,firefox"
        "SUPER SHIFT,H,exec,firefox,https://chatgpt.com"
        "SUPER SHIFT,N,exec,notify-send hello"
        "SUPER SHIFT,Q,killactive"
        "SUPER SHIFT,M,exit"
        "ALT,h,movefocus,l"
        "ALT,l,movefocus,r"
        "ALT,k,movefocus,u"
        "ALT,j,movefocus,d"

        # Forward macOS-style Command shortcuts to the focused application.
        "SUPER,A,sendshortcut,CTRL,A"
        "SUPER,C,sendshortcut,CTRL,C"
        "SUPER,V,sendshortcut,CTRL,V"
        "SUPER,X,sendshortcut,CTRL,X"
        "SUPER,Z,sendshortcut,CTRL,Z"
        "SUPER SHIFT,Z,sendshortcut,CTRL,SHIFT,Z"
        "SUPER,F,sendshortcut,CTRL,F"
        "SUPER,S,sendshortcut,CTRL,S"
        "SUPER,N,sendshortcut,CTRL,N"
        "SUPER,O,sendshortcut,CTRL,O"
        "SUPER,P,sendshortcut,CTRL,P"
        "SUPER,W,sendshortcut,CTRL,W"
        "SUPER,T,sendshortcut,CTRL,T"
        "SUPER,Q,sendshortcut,CTRL,Q"
      ];
    };
  };

  home.packages = with pkgs; [
    hyprpaper # notifications
    hyprland-qtutils
    hyprlock # lock streem
    hypridle # idle response
    waybar # toolbar
    rofi # app launcher
    wl-clipboard # clipboard
    # grim
    # slurp
    # brightnessctl
    # pavucontrol
  ];

  # Hyperpaper config
  home.file.".config/hypr/hyprpaper.conf".text = ''
    wallpaper {
      monitor =
      path = ~/.config/hypr/wallpapers
      fit_mode = cover
    }
  '';

}
