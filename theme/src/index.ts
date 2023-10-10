import build, { saveTheme } from "./build";
import { input as getInput } from "./funs";

const input = getInput();

if (input.indexOf("base00 = '")) {
  // From lua base 16 example:
  // \ base00 = '#1a1b26', base01 = '#16161e', base02 = '#2f3549', base03 = '#444b6a',
  // \ base04 = '#787c99', base05 = '#a9b1d6', base06 = '#cbccd1', base07 = '#d5d6db',
  // \ base08 = '#c0caf5', base09 = '#a9b1d6', base0A = '#0db9d7', base0B = '#9ece6a',
  // \ base0C = '#b4f9f8', base0D = '#2ac3de', base0E = '#bb9af7', base0F = '#f7768e'
  const clean = input.replace(/\n|\\|\s|'/g, "")
  const tokens = clean.split(",")
  const pairs = tokens.map(t => t.split("="))
  const theme = pairs.reduce((acc, pair) => ({...acc, [pair[0]]: pair[1]}), {}) as any
  saveTheme({COLOUR_00: theme.base00, COLOUR_01: theme.base08, COLOUR_02: theme.base0B, COLOUR_03: theme.base0A, COLOUR_04: theme.base0D, COLOUR_05: theme.base0E, COLOUR_06: theme.base0C, COLOUR_07: theme.base05, COLOUR_08: theme.base03, COLOUR_15: theme.base07, COLOUR_16: theme.base09, COLOUR_17: theme.base0F, COLOUR_18: theme.base01, COLOUR_19: theme.base02, COLOUR_20: theme.base04, COLOUR_21: theme.base06})
} else {
  const { color, foreground, background } = JSON.parse(getInput());
  build(color, foreground, background);
}
