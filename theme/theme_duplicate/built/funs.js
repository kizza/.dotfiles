"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.moveMatchToPosition = exports.insertColour = exports.removeColour = exports.colourClosestTo = exports.mapValues = exports.mapKeys = exports.randomiseArray = exports.formatNumber = exports.formatColour = exports.chunk = exports.flags = exports.input = void 0;
const chroma_js_1 = __importDefault(require("chroma-js"));
const { assign, keys } = Object;
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
exports.input = () => process.argv.slice(2).pop() || defaultInput;
exports.flags = (defaults) => {
    const pairs = exports.chunk(process.argv.slice(2), 2);
    console.log("pairs", pairs);
    const flags = pairs.reduce((acc, pair) => assign({}, acc, { [pair[0].replace(/-/g, "")]: pair[1] }), {});
    return assign(defaults, flags);
};
exports.chunk = (array, chunkSize) => {
    let i, j, chunked = [];
    for (i = 0, j = array.length; i < j; i += chunkSize) {
        chunked.push(array.slice(i, i + chunkSize));
    }
    return chunked;
};
exports.formatColour = (colour) => colour
    .replace("#", "")
    .match(/.{1,2}/g)
    .join("/");
exports.formatNumber = (number) => "00".substring(0, 2 - number.toString().length) + number;
exports.randomiseArray = (array) => {
    let output = [];
    array.reduce((acc, _) => {
        const r = Math.floor(Math.random() * acc.length);
        output.push(...acc.splice(r, r + 1));
        return acc;
    }, [...array]);
    return output;
};
exports.mapKeys = (record, fn) => keys(record).reduce((acc, key) => assign({}, acc, { [fn(key)]: record[key] }), {});
exports.mapValues = (record, fn) => keys(record).reduce((acc, key) => assign({}, acc, { [key]: fn(record[key]) }), {});
exports.colourClosestTo = (colours, match) => colours.reduce((acc, colour) => {
    // const distance = chroma.distance(
    //   colour.toString(),
    //   match.toString(),
    //   "rgb"
    // );
    const distance = chroma_js_1.default.deltaE(colour.toString(), match.toString(), 1, 3);
    return distance < acc.distance ? { best: colour, distance } : acc;
}, { best: undefined, distance: 1000 }).best;
exports.removeColour = (colours, strip) => colours.filter(colour => colour.toString() !== strip.toString());
exports.insertColour = (colours, add, index) => colours.splice(index, 0, add) && colours;
exports.moveMatchToPosition = (colours, match, position) => {
    const best = exports.colourClosestTo(colours, match);
    const filtered = exports.removeColour(colours, best);
    return exports.insertColour(filtered, best, position);
};
