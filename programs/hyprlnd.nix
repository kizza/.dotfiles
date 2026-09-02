{ config, pkgs, lib, ... }:

{
  wayland.windowManager.hyprland = {
    enable = true;
    configType = "lua";

    package = config.lib.nixGL.wrap pkgs.hyprland;

    extraConfig = ''
      hl.env("PATH", "${config.home.profileDirectory}/bin:/run/current-system/sw/bin:/usr/bin")

      hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1.6 })

      hl.on("hyprland.start", function()
        hl.exec_cmd("hyprpaper")
        hl.exec_cmd("waybar")
      end)

      hl.config({
        animations = { enabled = true },
        decoration = {
          active_opacity = 1.0,
          inactive_opacity = 0.8,
          rounding = 8,
          blur = { enabled = false },
        },
        general = {
          border_size = 3,
          col = { active_border = "rgba(ff7FBBB3)" },
          gaps_in = 5,
          gaps_out = 10,
        },
        input = { kb_layout = "au" },
      })

      hl.bind("CTRL + SPACE", hl.dsp.exec_cmd("rofi -show drun"))
      hl.bind("SUPER + RETURN", hl.dsp.exec_cmd("nixGLIntel ghostty"))
      hl.bind("SUPER + SHIFT + B", hl.dsp.exec_cmd("firefox"))
      hl.bind("SUPER + SHIFT + H", hl.dsp.exec_cmd("firefox https://chatgpt.com"))
      hl.bind("SUPER + SHIFT + N", hl.dsp.exec_cmd("notify-send hello"))
      hl.bind("SUPER + SHIFT + Q", hl.dsp.window.close())
      hl.bind("SUPER + SHIFT + M", hl.dsp.exit())
      hl.bind("ALT + h", hl.dsp.focus({ direction = "left" }))
      hl.bind("ALT + l", hl.dsp.focus({ direction = "right" }))
      hl.bind("ALT + k", hl.dsp.focus({ direction = "up" }))
      hl.bind("ALT + j", hl.dsp.focus({ direction = "down" }))

      hl.bind("SUPER + A", hl.dsp.send_shortcut({ mods = "CTRL", key = "A" }))
      hl.bind("SUPER + C", hl.dsp.send_shortcut({ mods = "CTRL", key = "C" }))
      hl.bind("SUPER + V", hl.dsp.send_shortcut({ mods = "CTRL", key = "V" }))
      hl.bind("SUPER + X", hl.dsp.send_shortcut({ mods = "CTRL", key = "X" }))
      hl.bind("SUPER + Z", hl.dsp.send_shortcut({ mods = "CTRL", key = "Z" }))
      hl.bind("SUPER + SHIFT + Z", hl.dsp.send_shortcut({ mods = "CTRL SHIFT", key = "Z" }))
      hl.bind("SUPER + F", hl.dsp.send_shortcut({ mods = "CTRL", key = "F" }))
      hl.bind("SUPER + S", hl.dsp.send_shortcut({ mods = "CTRL", key = "S" }))
      hl.bind("SUPER + N", hl.dsp.send_shortcut({ mods = "CTRL", key = "N" }))
      hl.bind("SUPER + O", hl.dsp.send_shortcut({ mods = "CTRL", key = "O" }))
      hl.bind("SUPER + P", hl.dsp.send_shortcut({ mods = "CTRL", key = "P" }))
      hl.bind("SUPER + W", hl.dsp.send_shortcut({ mods = "CTRL", key = "W" }))
      hl.bind("SUPER + T", hl.dsp.send_shortcut({ mods = "CTRL", key = "T" }))
      hl.bind("SUPER + Q", hl.dsp.send_shortcut({ mods = "CTRL", key = "Q" }))
    '';
  };

  xdg.dataFile."wayland-sessions/hyprland.desktop".text = ''
    [Desktop Entry]
    Name=Hyprland
    Comment=A dynamic tiling Wayland compositor
    Exec=env XDG_CURRENT_DESKTOP=Hyprland XDG_SESSION_DESKTOP=Hyprland XDG_SESSION_TYPE=wayland ${config.home.profileDirectory}/bin/start-hyprland --path ${config.home.profileDirectory}/bin/Hyprland
    Type=Application
    DesktopNames=Hyprland
  '';

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
