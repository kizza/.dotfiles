{ herdr, ... }:

{
  programs.herdr = {
    enable = true;
    package = herdr.packages.aarch64-darwin.default;
    settings = {
      ui.agent_panel_sort = "spaces";
      theme = {
        name = "terminal";
        custom = {
          accent = "#A3B8EF";
          surface0 = "#201F1F";
          surface1 = "#EFA6A2";
          surface_dim = "#263044";
          overlay0 = "#776A6A";
          overlay1 = "#A3B8EF";
          text = "#A3B8EF";
          subtext0 = "#776A6A";
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
      };
    };
  };
}
