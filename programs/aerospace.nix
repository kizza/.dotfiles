{ config, pkgs, lib, ... }:

# Make link available as eneded
# ln -s $(which aerospace) ~/.local/bin/aerospace

let
  aerospaceModule = import ../modules/aerospace.nix;
in
{
  # Ignore the upstream module (not up to date)
  disabledModules = [ "programs/aerospace.nix" ];

  # Import local module
  imports = [ aerospaceModule ];

  programs.aerospace = {
    enable = true;
    launchd = {
      enable = true;
      keepAlive = false;
    };
    userSettings = {
      after-startup-command = [
        "exec-and-forget ~/.local/bin/sketchybar" # Start sketchybar
      ];
      workspace-to-monitor-force-assignment = {
        "1" = "main"; # Code
        "2" = "main"; # Browse
        "3" = "main"; # Comms
        "4" = "main";
        "5" = "secondary"; # Secondary monitor (non-main).
      };
      # nb. ln -s $(which sketchybar) ~/.local/bin/sketchybar
      exec-on-workspace-change = [
        "/bin/zsh"
        "-c"
        "~/.local/bin/sketchybar --trigger aerospace_workspace_change FOCUSED_WORKSPACE=$AEROSPACE_FOCUSED_WORKSPACE"
      ];
      accordion-padding = 240;
      gaps = {
        inner.horizontal = 12;
        inner.vertical = 12;
        outer.left = 6;
        outer.bottom = 6;
        outer.top = 6;
        outer.right = 40; # Sketchybar gap
      };
      mode = {
        main.binding = {
          # Modes
          alt-w = "mode service";
          alt-2 = "workspace 2";
          alt-3 = "workspace 3";
          alt-4 = "workspace 4";
          alt-5 = "workspace 5";
          # Focus
          alt-h = "focus --boundaries all-monitors-outer-frame left";
          alt-j = "focus --boundaries all-monitors-outer-frame down";
          alt-k = "focus --boundaries all-monitors-outer-frame up";
          alt-l = "focus --boundaries all-monitors-outer-frame right";
          # Move
          alt-down = "move down";
          alt-up = "move up";
          alt-left = "move left";
          alt-right = "move right";
          alt-ctrl-down = "move-node-to-monitor --focus-follows-window next";
          alt-ctrl-up = "move-node-to-monitor --focus-follows-window prev";
          # Arrange
          alt-slash = "layout tiles accordion";
          alt-equal = "balance-sizes";
          alt-minus = "resize smart -200";
          alt-shift-equal = "resize smart +200"; # Plus
          alt-enter = "fullscreen";
          alt-quote = "join-with left";
          alt-backspace = "layout floating tiling";
        };
        service.binding = {
          s = "mode send";
          r = ["reload-config" "mode main"];
          z = ["fullscreen" "mode main"];
          x = ["layout floating tiling" "mode main"];
          backspace = ["flatten-workspace-tree" "mode main"];
        };
        send.binding = {
          "1" = ["move-node-to-workspace 1" "mode main"];
          "2" = ["move-node-to-workspace 2" "mode main"];
          "3" = ["move-node-to-workspace 3" "mode main"];
          "4" = ["move-node-to-workspace 4" "mode main"];
          "5" = ["move-node-to-workspace 5" "mode main"];
        };
      };
      on-window-detected = [
        {
          "if" = {app-id = "com.apple.finder";};
          run = ["layout floating"];
          check-further-callbacks = false;
        }
        {
          "if" = {app-id = "com.google.chrome.for.testing";};
          run = ["layout floating"];
          check-further-callbacks = false;
        }
        {
          "if" = {app-id = "com.microsoft.Outlook";};
          run = ["move-node-to-workspace 3 --focus-follows-window"];
          check-further-callbacks = false;
        }
        {
          "if" = {app-id = "com.tinyspeck.slackmacgap";};
          run = ["move-node-to-workspace 3 --focus-follows-window"];
          check-further-callbacks = false;
        }
      ];
    };
  };
}
