const fs = require("fs");

const date = "#(date '+%a, %b %d')";
const time = "#(date '+%-I:%M')";
const dir = "#{b:pane_current_path}";
const prefix = "#{?client_prefix,#[fg=black]PREFIX,} #{?pane_in_mode,#[fg=black]COPY ,}";

const separators = { left: '', right: '' };
// const separators = { left: '', right: '' };

const magnify = '󰍉'
// const magnify = ' '


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
    // inactiveTabBg: "color18",
    // inactiveTabFg: "color20",
    segment1: segment1,
    segment2: segment2,
    segment3: segment3,

    ...{
      inactiveTabBg: "colour18", // No background
      // activeTabFg: "green",
      inactiveTabFg: "colour20", // Subtle inactive labels
    }
  };
};

const icon = (restoreFg) => {
  const iconMap = {
    // nvim: `#[fg=green]#[fg=${restoreFg}]`,
    nvim: ``,
    // zsh: "",
    // zsh: " ",
    ".overmind-wrapp": `#[fg=red]#[fg=${restoreFg}]`,
    bash: " ",
    zsh: " ",
  };

  return Object.entries(iconMap)
    .reduceRight(
      (acc, [cmd, icon]) =>
        `#{?#{==:#{pane_current_command},${cmd}},${icon},${acc}}`,
      "#{pane_current_command}"
    );
}

const I = (variant) => {
  return "";
  if (variant === "active") {
    return `#[fg=colour20,italics]#I#[default]`;
  } else {
    return `#[italics]#I#[default]`;
  }
}

// If window name is the same as the current command, hide it to save space
const W = `#{?#{==:#{window_name},#{pane_current_command}},,#{window_name} }`;

/**
 * What the window is *for*, when paddck knows: the name the agent gave itself, or the prompt it was
 * opened with. Agent windows are otherwise all named after the wrapper running in them, so the tabs
 * read `.claude-wrapped` three times over. The daemon writes the label on the agent's pane and on
 * its window, and tmux answers with the pane's first — so a tab names the agent you are sitting
 * with, and the one working beside you when you are not. Unset, the window's own name gets its turn.
 */
const agentLabel = "#{=/24/\u{2026}:@paddck_label}";

/** State in the sidebar's own shapes: amber asks for you, blue is busy, dim is spare. */
const agentState = restoreFg =>
  `#{?#{==:#{@paddck_state},waiting},#[fg=color16]\u{25c9},#{?#{==:#{@paddck_state},working},#[fg=green],#[fg=${restoreFg}]\u{25cb}}}#[fg=${restoreFg}]`;

/** The label where there is one, and the window's own name beside its command icon where there is not. */
const title = restoreFg => `#{?#{@paddck_label},${agentState(restoreFg)} ${agentLabel},${W}${icon(restoreFg)}}`;

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
set -g status-right "${prefix}#[fg=${segment1},bg=${inactiveTabBg}]${separators.right}#[fg=${lightText},bg=${segment1}] ${time} #[fg=${segment2},bg=${segment1}]${separators.right}#[fg=${lightText},bg=${segment2}] ${date} #[fg=${segment3},bg=${segment2}]${separators.right}#[fg=colour18,bg=${segment3},bold] #S "

# Window status
set -g window-status-format "#[fg=${inactiveTabFg}]#[bg=${inactiveTabBg}]${I()}#[fg=${inactiveTabFg}] ${title(inactiveTabFg)} ${dir} #{?window_zoomed_flag,${magnify} ,}"
set -g window-status-current-format "#[fg=${inactiveTabBg}]${separators.left}#[fg=${activeTabFg}]${I('active')} ${title(activeTabFg)} ${dir}#[fg=${active}] #{?window_zoomed_flag,${magnify} ,}#[fg=${activeTabBg},bg=${inactiveTabBg}]${separators.left}"

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
set -g mode-style bg=magenta,fg=colour231
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
