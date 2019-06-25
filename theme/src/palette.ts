import chalk from "chalk";
import { spawn } from "child_process";
import chroma from "chroma-js";
import getPixels from "get-pixels";
import { uniqBy } from "lodash";
import path from "path";
import build from "./build";
import {
  chunk,
  moveMatchToPosition,
  randomiseArray,
  removeColour,
  flags
} from "./funs";
import { Colour } from "./models";

const commands = flags({
  darken: false,
  lighten: false,
  pick: false,
  use: false,
  random: false
});

const getImage = (): Promise<string> =>
  new Promise((resolve, reject) => {
    const fileName = "temp.png";
    const paste = spawn("pngpaste", [fileName]);
    paste.stderr.on("data", reject);
    paste.on("close", () => resolve(fileName));
  });

const gePalette = (fileName: string): Promise<Colour[]> =>
  new Promise((resolve, reject) =>
    getPixels(
      path.join(__dirname, "../", fileName),
      (err: Error, result: any) => {
        if (err) {
          return reject(err);
        }
        const pixels = chunk(result.data, 4);
        const topFive = pixelFrequency(pixels, 5);
        const filtered = uniqBy(pixels, pixel => pixel.toString()).filter(
          pixel =>
            topFive.find(top => pixel.toString() === top.toString()) !==
            undefined
        );
        resolve(filtered.map(x => chroma(x[0], x[1], x[2], x[3], "rgb")));
      }
    )
  );

const pixelFrequency = (pixels: number[][], limit: number) => {
  const frequency: any = {};
  const key = (array: number[]) => array.join(",");
  pixels.forEach(pixel => {
    if (frequency[key(pixel)] !== undefined) {
      frequency[key(pixel)]++;
    } else {
      frequency[key(pixel)] = 0;
    }
  });

  const items = Object.keys(frequency).map(key => [key, frequency[key]]);
  items.sort((first, second) => second[1] - first[1]);
  return items.slice(0, limit).map(item => item[0].split(","));
};

const padColours = (colours: Colour[]) =>
  colours
    .concat(
      [chroma.average(colours, "rgb")],
      chroma
        .scale(colours)
        .mode("lch")
        .colors(6 - colours.length - 1)
        .map(x => chroma(x))
    )
    .slice(0, 6);

const randomiseColours = (colours: Colour[]) =>
  commands.random !== false ? randomiseArray(colours) : colours;

const printColours = (description = "Colours") => (colours: chroma.Color[]) => {
  console.log(description);
  console.log(
    colours.map(colour => chalk.bgHex(colour.toString())("   ")).join("")
  );
  return colours;
};

const useBackground = (
  colours: Colour[]
): { background: Colour; colours: Colour[] } => {
  const index =
    commands.use !== false
      ? parseInt(commands.use) - 1
      : commands.pick !== false
      ? parseInt(commands.pick) - 1
      : 0;
  return {
    background: colours[index],
    colours:
      commands.pick !== false ? removeColour(colours, colours[index]) : colours
  };
};

const toString = (colours: Colour[]) =>
  colours.map(colour => colour.toString());

const organiseColours = (colours: Colour[]) =>
  Promise.resolve(colours)
    .then(colours => moveMatchToPosition(colours, "cyan", 5))
    .then(colours => moveMatchToPosition(colours, "magenta", 4))
    .then(colours => moveMatchToPosition(colours, "blue", 3))
    .then(colours => moveMatchToPosition(colours, "yellow", 2))
    .then(colours => moveMatchToPosition(colours, "red", 0)) // Red
    .then(colours => moveMatchToPosition(colours, "green", 1)); // Green

const compile = (colours: Colour[], background: Colour) => {
  let bg = background.darken(
    parseFloat(commands.darken === false ? 1 : commands.darken)
  );
  const fg = chroma("#eeeeee");
  const base = [
    bg,
    ...colours,
    fg,
    bg.brighten(parseFloat(commands.lighten === false ? 1 : commands.lighten)),
    ...colours.map(colour => colour.brighten(0.2)),
    fg.brighten()
  ];

  build(toString(base), fg.toString(), bg.toString());
};

getImage()
  .then(fileName => gePalette(fileName))
  .then(printColours("From file"))
  .then(_colours => {
    const { background, colours } = useBackground(_colours);
    return Promise.resolve(colours)
      .then(printColours("After background"))
      .then(padColours)
      .then(printColours("Padded"))
      .then(organiseColours)
      .then(printColours("Organised"))
      .then(randomiseColours)
      .then(printColours("Randomised"))
      .then(colours => compile(colours, background));
  })
  .catch(e => {
    console.error(chalk.yellow("An error occurred", e));
    process.exit(1);
  });
