const fs = require("fs");

const date = "#(date '+%a, %b %d')";
const time = "#(date '+%I:%M')";
const dir = "#{b:pane_current_path}";
const prefix = "#{?client_prefix,#[fg=black]PREFIX,} #{?pane_in_mode,#[fg=black]COPY ,}";

const colours = dark => {
  const background = "black";
  let active = "green";
  let lightText = background;
  let darkText = active;
  let segment1 = "colour20"
  let segment2 = "colour8"
  let segment3 = "colour19"

  if (dark) {
    lightText = "white";
    segment1 = "colour18"
    segment2 = "colour19"
    segment3 = "colour20"
  }

  return {
    active: active,
    background: background,
    lightText: lightText,
    darkText: darkText,
    activeTabBg: background,
    activeTabFg: darkText,
    inactiveTabBg: active,
    inactiveTabFg: background,
    segment1: segment1,
    segment2: segment2,
    segment3: segment3,
  };
};

const buildTheme = ({
  active,
  background,
  lightText,
  activeTabBg,
  activeTabFg,
  inactiveTabBg,
  inactiveTabFg,
  segment1,
  segment2,
  segment3
}) =>
  `
# Status update interval
set -g status-interval 1

# Basic status bar colors/#{
set -g status-style bg=${inactiveTabBg},fg=colour240

# Primary status background
set -g status-bg ${inactiveTabBg}

# Left side of status bar
set -g status-left-style bg=${active}
set -g status-left ""
set -g status-left-length 4

# Right side of status bar
set -g status-right-style bg=${inactiveTabBg},fg=colour243
set -g status-right-length 150
set -g status-right "${prefix}#[fg=${segment1},bg=${inactiveTabBg}]#[fg=${lightText},bg=${segment1}] ${time} #[fg=${segment2},bg=${segment1}]#[fg=${lightText},bg=${segment2}] ${date} #[fg=${segment3},bg=${segment2}]#[fg=colour18,bg=${segment3},bold] #S "

# Window status
set -g window-status-format "#[fg=${inactiveTabFg}]#[bg=${inactiveTabBg}] #I:#W ${dir} #{?window_zoomed_flag, ,}"
set -g window-status-current-format " #[fg=${activeTabFg}]#I:#[fg=${activeTabFg}]#W ${dir}#[fg=${active}] #{?window_zoomed_flag, ,}"

# Current window status
set -g window-status-current-style bg=${activeTabBg},fg=${activeTabFg}

# Window with activity status
set -g window-status-activity-style bg=colour31,fg=${active}  # fg and bg are flipped here due to a bug in tmux

# Window separator
set -g window-status-separator ""

# Window status alignment
# set -g status-justify centre

# Pane border
set -g pane-border-style bg=default,fg=colour18

# Active pane border
set -g pane-active-border-style bg=default,fg=colour18

# Pane number indicator
set -g display-panes-colour ${active}
set -g display-panes-active-colour colour245

# Clock mode
set -g clock-mode-colour ${active}
set -g clock-mode-style 24

# Message
set -g message-style bg=${background},fg=${active}

# Command message
set -g message-command-style bg=red,fg=yellow

# Mode
set -g mode-style bg=${active},fg=colour231
`;

const homedir = require("os").homedir();
const writeTheme = contents =>
  fs.writeFile(homedir + "/.tmux-theme.conf", contents, "utf8", e => {
    console.log(e || "Done");
  });

writeTheme(
  buildTheme(colours(true))
  // buildTheme(colours(process.env.BASE16_THEME.indexOf("light") === -1))
);
