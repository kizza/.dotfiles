#!/usr/bin/env node

const fs = require("node:fs");
const os = require("node:os");
const chroma = require("chroma-js");

const configFile = `${os.homedir()}/.config/herdr/config.toml`;

const COLOR_MAP = {
  0: "00", 1: "08", 2: "0B", 3: "0A", 4: "0D", 5: "0E", 6: "0C", 7: "05", 8: "03", 9: "08", 10: "0B", 11: "0A", 12: "0D", 13: "0E", 14: "0C", 15: "07", 16: "09", 17: "0F", 18: "01", 19: "02", 20: "04", 21: "06",
};

function hex(colour) {
  const base16 = COLOR_MAP[colour];
  if (!base16) throw new Error(`Unknown colour ${colour}`);
  const env = process.env[`BASE16_COLOR_${base16}_HEX`];
  if (!env) throw new Error(`Missing BASE16_COLOR_${base16.toUpperCase()}_HEX`);
  return chroma(env);
}

const bg = hex(0)

const THEME = {
  accent: hex(16), // Primary tab, buttons, modal border

  // panel_bg: hex(18),
  surface0: hex(18), // Secondary tab
  surface1: hex(1), // ?
  surface_dim: chroma(hex(16)).mix(bg, 0.94).saturate(0.3),
  // surface_dim: hex(16),

  overlay0: hex(8), // Primary text labels, scroll track
  overlay1: hex(16), // interface icons, scroll thumb

  text: hex(16), // Selected session
  subtext0: hex(8), // Unselected session

  // red: hex("08"),
  // peach: hex("09"),
  // yellow: hex("0A"),
  // green: hex("0B"),
  // teal: hex("0C"),
  // blue: hex("0D"),
  // mauve: hex("0E"),
};

function buildTheme() {
  const lines = ["[theme.custom]"];
  for (const [key, value] of Object.entries(THEME)) {
    if (!value) continue;
    lines.push(`${key} = "${value.hex().toUpperCase()}"`);
  }

  return lines.join("\n");
}

const replacement = buildTheme();
const contents = fs.readFileSync(configFile, "utf8");
const themeSection = /^\[theme\.custom\][\s\S]*?(?=^\[[^\]]+\]\s*$|(?![\s\S]))/m;
if (!themeSection.test(contents)) {
  throw new Error("[theme.custom] section not found");
}

const updated = contents.replace(themeSection, `${replacement}\n\n`);
fs.writeFileSync(configFile, updated);
console.log(`Updated ${configFile}`);
