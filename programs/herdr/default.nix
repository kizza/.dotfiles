{ pkgs, edgePkgs, ... }:

let
  herdr-layout = import ./layout.nix { inherit pkgs; };
in
{
  programs.herdr = {
    enable = true;
    package = edgePkgs.herdr; # Use edge packages for latest
    settings = {
      ui = {
        agent_panel_sort = "spaces";
        # agent_panel_sort = "priority";
        sidebar_width = 32;
        sidebar_max_width = 220;
        toast.delivery = "herdr";
        sound.enabled = true;
      };
      theme = {
        name = "terminal";
        custom = {
          accent = "#A3B8EF";
          active_row_bg = "#332a23";
          selection_bg = "#454545";
          overlay0 = "#454545"; # Secondary text, unfocused pane border
          surface_dim = "#263044";
          # text = "#A3B8EF";
          # overlay1 # Unfocused tab background
          # panel_bg = "#201F1F"; # Leave transparent?
          # sidebar_bg = "#191919"; # Leave transparent?
          # subtext0 = "#776A6A";
          # surface0 = "#201F1F"; # Unfocused tabs
          # surface1 = "#EFA6A2"; # Underline for binding+w

          # Colours
          blue = "#89b4fa";
          green = "#80C990";
          red = "#f38ba8";
          yellow = "#f9e2af";
        };
      };
      keys = {
        prefix = "ctrl+b";

        # Tab navigation (tmux: M-{ / M-})
        # previous_tab = "alt+shift+bracketleft";
        # next_tab = "alt+shift+bracketright";

        # Navigate...
        goto = "prefix+w"; # all windows
        workspace_picker = "prefix+s"; # workspaces
        # focus_agent = "prefix+a+1..9"; # agents
        settings = "prefix+;"; # Settings

        # New tab (tmux: prefix c)
        new_tab = "prefix+c";
        rename_tab = "prefix+,";
        rename_workspace = "prefix+$";

        # Pane splits (tmux: prefix " and prefix %)
        split_horizontal = "prefix+quote";
        split_vertical = "prefix+percent";

        # Pane navigation (tmux: C-h/j/k/l, no prefix)
        focus_pane_left = "ctrl+h";
        focus_pane_down = "ctrl+j";
        focus_pane_up = "ctrl+k";
        focus_pane_right = "ctrl+l";

        # Reorder tabs, following the moved tab (tmux: prefix { and prefix }, swap-window).
        # Literal punctuation only — "braceleft" parses but herdr then disables the binding.
        move_tab_previous = "prefix+{";
        move_tab_next = "prefix+}";

        # Pane resize (tmux: prefix k and prefix j for -x 70%/30%, prefix = for even-horizontal).
        # tmux's `-` main-horizontal is left out on purpose: it restructures the tree rather than
        # nudging ratios, and layout.apply would rebuild panes that have agents running in them.
        command = [
          {
            key = "prefix+k";
            type = "shell";
            command = "${herdr-layout}/bin/herdr-layout 0.7";
            description = "focused pane 70%";
          }
          {
            key = "prefix+j";
            type = "shell";
            command = "${herdr-layout}/bin/herdr-layout 0.3";
            description = "focused pane 30%";
          }
          {
            key = "prefix+=";
            type = "shell";
            command = "${herdr-layout}/bin/herdr-layout even";
            description = "even panes";
          }
        ];
      };
    };
  };
}
