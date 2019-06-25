import chroma from "chroma-js";
import { Colour } from "./models";

const { assign } = Object;

const defaultInput = `{
  "name": "",
  "author": "",
  "color": [
    "#002b36",
    "#dc322f",
    "#859900",
    "#b58900",
    "#268bd2",
    "#6c71c4",
    "#2aa198",
    "#93a1a1",
    "#657b83",
    "#dc322f",
    "#859900",
    "#b58900",
    "#268bd2",
    "#6c71c4",
    "#2aa198",
    "#fdf6e3"
  ],
  "foreground": "#586e75",
  "background": "#fdf6e3"
}`;

export const input = () => process.argv.slice(2).pop() || defaultInput;

export const flags = (defaults: Record<string, any>) => {
  const pairs = chunk(process.argv.slice(2), 2);
  const flags = pairs.reduce(
    (acc, pair) => assign({}, acc, { [pair[0].replace(/-/g, "")]: pair[1] }),
    {}
  );
  return assign(defaults, flags);
};

export const chunk = (array: any[], chunkSize: number) => {
  let i,
    j,
    chunked = [];
  for (i = 0, j = array.length; i < j; i += chunkSize) {
    chunked.push(array.slice(i, i + chunkSize));
  }
  return chunked;
};

export const formatColour = (colour: string) =>
  colour
    .replace("#", "")
    .match(/.{1,2}/g)!
    .join("/");

export const formatNumber = (number: number) =>
  "00".substring(0, 2 - number.toString().length) + number;

export const randomiseArray = (array: any[]) => {
  let output: any[] = [];
  array.reduce(
    (acc, _) => {
      const r = Math.floor(Math.random() * acc.length);
      output.push(...acc.splice(r, r + 1));
      return acc;
    },
    [...array]
  );
  return output;
};

export const colourClosestTo = (colours: Colour[], match: string) =>
  colours.reduce(
    (acc: { best: Colour | undefined; distance: number }, colour) => {
      // const distance = chroma.distance(
      //   colour.toString(),
      //   match.toString(),
      //   "rgb"
      // );
      const distance = chroma.deltaE(colour.toString(), match.toString(), 1, 3);
      return distance < acc.distance ? { best: colour, distance } : acc;
    },
    { best: undefined, distance: 1000 }
  ).best;

export const removeColour = (colours: Colour[], strip: Colour) =>
  colours.filter(colour => colour.toString() !== strip.toString());

export const insertColour = (colours: Colour[], add: Colour, index: number) =>
  colours.splice(index, 0, add) && colours;

export const moveMatchToPosition = (
  colours: Colour[],
  match: string,
  position: number
) => {
  const best = colourClosestTo(colours, match)!;
  const filtered = removeColour(colours, best);
  return insertColour(filtered, best, position);
};
