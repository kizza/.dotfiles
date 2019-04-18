const fs = require('fs')

const theme = process.env.THEME
const date = '#(date \'+%a, %b %d\')'
const time = '#(date \'+%I:%M\')'
const dir = '#{b:pane_current_path}'
const prefix = '#{?client_prefix,#[fg=black]PREFIX,} '

const colours = (dark) => {
  const background = 'black'
  const lightGrey = 'colour245'
  let active = 'green'
  let lightText = background
  let darkText = 'colour232'

  if (dark) {
    active = 'green'
    lightText = 'white'
    darkText = active
  }

  return {
    active: active,
    background: background,
    lightText: lightText,
    darkText: darkText,
    activeTabBg: background,
    activeTabFg: darkText,
    inactiveTabBg: active,
    inactiveTabFg: background
  }
}

const buildTheme = ({
  active,
  background,
  lightText,
  activeTabBg,
  activeTabFg,
  inactiveTabBg,
  inactiveTabFg
}) =>
`
# Status update interval
set -g status-interval 1

# Basic status bar colors
set -g status-fg colour240
set -g status-bg ${active}

# Left side of status bar
set -g status-left-bg ${active}
set -g status-left ""
set -g status-left-length 4

# Right side of status bar
set -g status-right-bg ${active}
set -g status-right-fg colour243
set -g status-right-length 150
set -g status-right "${prefix}#[fg=colour235,bg=${active}]#[fg=${lightText},bg=colour235] ${time} #[fg=colour240,bg=colour235]#[fg=${lightText},bg=colour240] ${date} #[fg=colour245,bg=colour240]#[fg=colour232,bg=colour245,bold] #S "

# Window status
set -g window-status-format "#[fg=${inactiveTabFg}]#[bg=${inactiveTabBg}] #I:#W ${dir}#F "
set -g window-status-current-format " #[fg=colour240]#I:#[fg=${activeTabFg}]#W ${dir}#[fg=${active}] #{?window_zoomed_flag,🔍 ,}"

# Current window status
set -g window-status-current-bg ${activeTabBg}
set -g window-status-current-fg ${activeTabFg}

# Window with activity status
set -g window-status-activity-bg colour31  # fg and bg are flipped here due to
set -g window-status-activity-fg ${active} # a bug in tmux

# Window separator
set -g window-status-separator ""

# Window status alignment
# set -g status-justify centre

# Pane border
set -g pane-border-bg default
set -g pane-border-fg colour238

# Active pane border
set -g pane-active-border-bg default
set -g pane-active-border-fg ${active}

# Pane number indicator
set -g display-panes-colour ${active}
set -g display-panes-active-colour colour245

# Clock mode
set -g clock-mode-colour ${active}
set -g clock-mode-style 24

# Message
set -g message-bg ${background}
set -g message-fg ${active}

# Command message
set -g message-command-bg red
set -g message-command-fg yellow

# Mode
set -g mode-bg ${active}
set -g mode-fg colour231
  `;

const homedir = require('os').homedir();
const writeTheme = (contents) =>
  fs.writeFile(homedir + '/tmux-theme.conf', contents, 'utf8', (e) => {
    console.log(e || 'Done')
  });

writeTheme(
  buildTheme(
    colours(process.env.BASE16_THEME.indexOf('dark') !== -1)
  )
)
