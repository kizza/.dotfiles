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
          cmd-alt-1 = "workspace 1";
          cmd-alt-2 = "workspace 2";
          cmd-alt-3 = "workspace 3";
          cmd-alt-4 = "workspace 4";
          cmd-alt-5 = "workspace 5";
          # Focus
          cmd-alt-h = "focus --boundaries all-monitors-outer-frame left";
          cmd-alt-j = "focus --boundaries all-monitors-outer-frame down";
          cmd-alt-k = "focus --boundaries all-monitors-outer-frame up";
          cmd-alt-l = "focus --boundaries all-monitors-outer-frame right";
          # Move
          cmd-alt-down = "move down";
          cmd-alt-up = "move up";
          cmd-alt-left = "move left";
          cmd-alt-right = "move right";
          cmd-alt-ctrl-down = "move-node-to-monitor --focus-follows-window next";
          cmd-alt-ctrl-up = "move-node-to-monitor --focus-follows-window prev";
          # Arrange
          cmd-alt-slash = "layout tiles accordion";
          cmd-alt-equal = "balance-sizes";
          cmd-alt-minus = "resize smart -200";
          cmd-alt-shift-equal = "resize smart +200"; # Plus
          cmd-alt-enter = "fullscreen";
          cmd-alt-quote = "join-with left";
          cmd-alt-backspace = "layout floating tiling";
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
