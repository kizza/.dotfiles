{ config, pkgs, lib, ... }:

let
  # `aerospace` on PATH is the CLI client; the server is the app bundle beside it, and the launchd
  # agent below already owns that. Kickstarting the agent is the only start that keeps the ownership
  # — `open`ing the bundle by hand goes through LaunchServices, leaving launchd reporting the job as
  # not running while a server it can neither see nor stop is up.
  startAerospace = pkgs.writeShellScriptBin "start-aerospace" ''
    # Clear any server started outside launchd, which kickstart wouldn't replace
    /usr/bin/pkill -x AeroSpace || true
    for _ in 1 2 3 4 5 6 7 8 9 10; do
      /usr/bin/pgrep -x AeroSpace >/dev/null 2>&1 || break
      sleep 0.2
    done

    exec /bin/launchctl kickstart -k "gui/$(/usr/bin/id -u)/${config.launchd.agents.aerospace.config.Label}"
  '';

  # SwipeAeroSpace reads the AeroSpace socket once, at launch, and sits there disconnected if it
  # loses the race — which it did as a login item, by about a second. Starting it from
  # after-startup-command below is the only point at which the server is known to be listening.
  startSwipeAerospace = pkgs.writeShellScriptBin "start-swipe-aerospace" ''
    /usr/bin/pkill -x SwipeAeroSpace || true
    sleep 0.5 # Let the old instance go before open considers relaunching it

    exec /usr/bin/open -a /Applications/SwipeAeroSpace.app
  '';

  # A verbose script to execute, to change the border colour based on state. Absolute paths because
  # AeroSpace runs this through launchd's PATH, which carries neither the nix profile nor ~/.local/bin
  aerospaceBin = "${pkgs.aerospace}/bin/aerospace";
  bordersBin = "${pkgs.jankyborders}/bin/borders";

  updateBordersColour = builtins.replaceStrings ["\n" "\\"] [" " ""] ''
    exec-and-forget \
    FS=$(${aerospaceBin} list-windows --focused --format "%{window-is-fullscreen}"); \
    LAYOUT=$(${aerospaceBin} list-windows --focused --format "%{window-layout}"); \
    if [ "$FS" = "true" ]; then ${bordersBin} active_color=0xffffffff; \
    elif [ "$LAYOUT" = "floating" ]; then ${bordersBin} active_color=0xffD699B6; \
    else ${bordersBin} active_color=0xff7FBBB3; fi
  '';

  # Define apps that should float
  floatingApps = [
    "com.1password.1password"
    "com.apple.Preview"
    "com.apple.QuickTimePlayerX"
    "com.apple.TextEdit"
    "com.apple.finder"
    "com.getcleanshot.app-setapp"
    "com.google.chrome.for.testing"
    "com.macpaw.CleanMyMac-setapp"
    "com.microsoft.Excel"
    "com.microsoft.teams2"
    "com.postmanlabs.mac"
    "com.runningwithcrayons.Alfred-Preferences"
    "md.obsidian"
    "ru.keepcoder.Telegram"
  ];

  # Helper function to create floating window rules
  mkFloatingRule = appId: {
    "if" = { app-id = appId; };
    run = ["layout floating"];
    check-further-callbacks = false;
  };
in
{
  home.packages = [startAerospace]; # The supported way to start or restart the server by hand

  programs.aerospace = {
    enable = true;
    launchd = {
      enable = true;
      keepAlive = false;
    };
    settings = {
      config-version = 2; # https://nikitabobko.github.io/AeroSpace/guide#config-version
      persistent-workspaces = ["1" "2" "3" "4" "5"];
      # Everything downstream of the window manager starts here, where the server is up
      after-startup-command = [
        "exec-and-forget ${config.sketchybar.start}/bin/start-sketchybar"
        "exec-and-forget ${startSwipeAerospace}/bin/start-swipe-aerospace"
      ];
      workspace-to-monitor-force-assignment = {
        "1" = "main"; # Code
        "2" = "main"; # Browse
        "3" = "main"; # Comms
        "4" = "main";
        "5" = "secondary"; # Secondary monitor (non-main).
      };
      exec-on-workspace-change = [
        "/bin/sh"
        "-c"
        "${pkgs.sketchybar}/bin/sketchybar --trigger aerospace_workspace_change FOCUSED_WORKSPACE=$AEROSPACE_FOCUSED_WORKSPACE"
      ];
      on-focus-changed = [updateBordersColour];
      accordion-padding = 240;
      gaps = {
        inner.horizontal = 12;
        inner.vertical = 12;
        outer.left = 6;
        outer.bottom = 6;
        outer.top = 6;
        outer.right = 56; # Sketchybar gap
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
          alt-backspace = ["layout floating tiling" updateBordersColour]; # Show floating border
        };
        service.binding = {
          s = "mode send";
          r = ["reload-config" "mode main"];
          z = ["fullscreen" "mode main" updateBordersColour]; # Show focused border
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
      on-window-detected =
        # Make floating rules from app ids above
        (map mkFloatingRule floatingApps)
        # Manual window detection rules...
        ++ [
        {
          "if" = {app-id = "com.mitchellh.ghostty";};
          run = ["move-node-to-workspace 1 --focus-follows-window"];
          check-further-callbacks = false;
        }
        {
          "if" = {app-id = "com.google.Chrome";};
          run = ["move-node-to-workspace 1 --focus-follows-window"];
          check-further-callbacks = false;
        }
        {
          "if" = {app-id = "company.thebrowser.Browser";};
          run = ["move-node-to-workspace 2 --focus-follows-window"];
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
