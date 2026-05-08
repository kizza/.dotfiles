{ config, pkgs, lib, ... }:

{
  wayland.windowManager.hyprland = {
    enable = true;

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
        "SUPER,T,exec,nixGLIntel ghostty"
        "SUPER,B,exec,firefox"
        "SUPER,H,exec,firefox,https://chatgpt.com"
        "SUPER,N,exec,notify-send hello"
        "SUPER,Q,killactive"
        "SUPER,A,exec,gnome-terminal"
        "SUPER,M,exit"
        "ALT,h,movefocus,l"
        "ALT,l,movefocus,r"
        "ALT,k,movefocus,u"
        "ALT,j,movefocus,d"
        "SUPER,A,sendshortcut,CTRL,A"
        "SUPER,C,sendshortcut,CTRL,C"
        "SUPER,V,sendshortcut,CTRL,V"
        "SUPER,X,sendshortcut,CTRL,X"
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
