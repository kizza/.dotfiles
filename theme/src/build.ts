import chroma from "chroma-js";
import fs from "fs";
import { formatNumber, formatColour } from "./funs";

const { assign, keys } = Object;

export default (color: string[], foreground: string, background: string) => {
  const hex: Record<string, string> = Array.from(color.keys()).reduce(
    (acc, i) =>
      assign({}, acc, {
        [`COLOUR${formatNumber(i)}`]: color[i]
      }),
    {
      NORMAL_FOREGROUND: foreground,
      NORMAL_BACKGROUND: background,
      LIGHTER_FOREGROUND: chroma(foreground)
        .brighten(0.1)
        .toString(),
      DARKER_FOREGROUND: chroma(foreground)
        .darken(0.1)
        .toString(),
      LIGHTER_BACKGROUND: chroma(background)
        .brighten(0.2)
        .toString(),
      SELECTION_BACKGROUND: chroma(background)
        .brighten(0.3)
        .toString()
    }
  );

  const colours: Record<string, string> = keys(hex).reduce(
    (acc, key) =>
      assign({}, acc, {
        [key]: formatColour(hex[key])
      }),
    {}
  );

  fs.readFile("templates/shell.template.sh", "utf8", (_, buffer) => {
    const theme = keys(colours).reduce(
      (acc, key) => acc.replace(new RegExp(key, "g"), colours[key]),
      buffer
    );

    fs.writeFile("dist/shell.theme.sh", theme, "utf8", e => {
      console.log(e || "Done");
    });
  });
};
