import chroma from "chroma-js";
import fs from "fs";
import {formatNumber, formatColour, randomiseArray, mapValues} from "./funs";
import {Colour} from "./models";

const {assign, keys} = Object;

export default (color: string[], foreground: string, background: string) => {
  const hex: Record<string, string> = Array.from(color.keys()).reduce(
    (acc, i) =>
      assign({}, acc, {
        [`COLOUR_${formatNumber(i)}`]: color[i]
      }),
    {
      NORMAL_FOREGROUND: foreground,
      NORMAL_BACKGROUND: background,
      COLOUR_21: chroma(foreground) // Lighter forground
        .brighten(0.1)
        .toString(),
      COLOUR_20: chroma(foreground) // Lighter forground
        .darken(0.1)
        .toString(),
      COLOUR_18: chroma(background) // Lighter background
        .brighten(0.2)
        .toString(),
      COLOUR_19: chroma(background) // Selection background
        .brighten(0.3)
        .toString()
    }
  );

  const additional = randomiseArray(color).map(x => chroma(x).saturate(1));
  // const additional: Colour[] = chroma
  //   .scale(color)
  //   .mode("lch")
  //   .colors(2)
  //   .map(x => chroma(x));
  hex["COLOUR_16"] = additional[0].toString();
  hex["COLOUR_17"] = additional[1].toString();

  saveTheme(hex);
};

export const saveTheme = (hex: Record<string, string>) => {
  const os = require("os")
  const colours = mapValues(hex, formatColour)

  fs.readFile("templates/shell.template.sh", "utf8", (_, buffer) => {
    console.log('saving', colours)
    const theme = keys(colours).reduce(
      (acc, key) => acc.replace(new RegExp(key, "g"), colours[key]),
      buffer
    );

    fs.writeFile("dist/shell.theme.sh", theme, "utf8", e => {
      console.log(e || "Done");
    });
  });
};
