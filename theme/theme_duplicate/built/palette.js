"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const chalk_1 = __importDefault(require("chalk"));
const child_process_1 = require("child_process");
const chroma_js_1 = __importDefault(require("chroma-js"));
const get_pixels_1 = __importDefault(require("get-pixels"));
const lodash_1 = require("lodash");
const path_1 = __importDefault(require("path"));
const build_1 = __importDefault(require("./build"));
const funs_1 = require("./funs");
const commands = funs_1.flags({
    darken: false,
    lighten: false,
    pick: false,
    use: false,
    random: false,
    bg: false
});
const getImage = () => new Promise((resolve, reject) => {
    const fileName = "temp.png";
    const paste = child_process_1.spawn("pngpaste", [fileName]);
    paste.stderr.on("data", reject);
    paste.on("close", () => resolve(fileName));
});
const gePalette = (fileName) => new Promise((resolve, reject) => get_pixels_1.default(path_1.default.join(__dirname, "../", fileName), (err, result) => {
    if (err) {
        return reject(err);
    }
    const pixels = funs_1.chunk(result.data, 4);
    const topFive = pixelFrequency(pixels, 5);
    const filtered = lodash_1.uniqBy(pixels, pixel => pixel.toString()).filter(pixel => topFive.find(top => pixel.toString() === top.toString()) !==
        undefined);
    resolve(filtered.map(x => chroma_js_1.default(x[0], x[1], x[2], x[3], "rgb")));
}));
const pixelFrequency = (pixels, limit) => {
    const frequency = {};
    const key = (array) => array.join(",");
    pixels.forEach(pixel => {
        if (frequency[key(pixel)] !== undefined) {
            frequency[key(pixel)]++;
        }
        else {
            frequency[key(pixel)] = 0;
        }
    });
    const items = Object.keys(frequency).map(key => [key, frequency[key]]);
    items.sort((first, second) => second[1] - first[1]);
    return items.slice(0, limit).map(item => item[0].split(","));
};
const padColours = (colours) => colours
    .concat([chroma_js_1.default.average(colours, "rgb")], chroma_js_1.default
    .scale(colours)
    .mode("lch")
    .colors(6 - colours.length - 1)
    .map(x => chroma_js_1.default(x)))
    .slice(0, 6);
const randomiseColours = (colours) => commands.random !== false ? funs_1.randomiseArray(colours) : colours;
const randomiseSomeColours = (colours) => {
    if (commands.random === false)
        return colours;
    const [red, green, ...others] = colours;
    return [red, green, ...funs_1.randomiseArray(others)];
};
const printColour = (colour) => chalk_1.default.bgHex(colour.toString())("   ");
const printColours = (description = "Colours") => (colours) => {
    console.log(description);
    console.log(colours.map(printColour).join(""));
    return colours;
};
const useBackground = (colours) => {
    const index = commands.use !== false
        ? parseInt(commands.use) - 1
        : commands.pick !== false
            ? parseInt(commands.pick) - 1
            : 0;
    const background = commands.bg ? chroma_js_1.default(`#${commands.bg}`) : colours[index];
    return {
        background: background,
        colours: commands.pick !== false ? funs_1.removeColour(colours, colours[index]) : colours
    };
};
const toString = (colours) => colours.map(colour => colour.toString());
const organiseColours = (colours) => Promise.resolve(colours)
    .then(colours => funs_1.moveMatchToPosition(colours, "cyan", 5))
    .then(colours => funs_1.moveMatchToPosition(colours, "magenta", 4))
    .then(colours => funs_1.moveMatchToPosition(colours, "blue", 3))
    .then(colours => funs_1.moveMatchToPosition(colours, "yellow", 2))
    .then(colours => funs_1.moveMatchToPosition(colours, "red", 0)) // Red
    .then(colours => funs_1.moveMatchToPosition(colours, "green", 1)); // Green
const compile = (colours, background) => {
    let bg = background;
    if (commands.darken) {
        // let bg = background.darken(
        //   parseFloat(commands.darken === false ? 1 : commands.darken/2)
        // );
        bg = background.darken(parseFloat(commands.darken));
    }
    console.log("commands", commands);
    let fg = chroma_js_1.default("#eeeeee");
    if (commands.random !== false) {
        fg = randomiseColours(colours)[0].brighten(3);
    }
    const base = [
        bg,
        ...colours,
        fg,
        bg.brighten(parseFloat(commands.lighten === false ? 1 : commands.lighten)),
        ...colours.map(colour => colour.brighten(0.2)),
        fg.brighten()
    ];
    build_1.default(toString(base), fg.toString(), bg.toString());
};
getImage()
    .then(fileName => gePalette(fileName))
    .then(printColours("From file"))
    .then(_colours => {
    const { background, colours } = useBackground(randomiseColours(_colours));
    return Promise.resolve(colours)
        .then(printColours("After background"))
        .then(padColours)
        .then(printColours("Padded"))
        .then(organiseColours)
        .then(printColours("Organised"))
        // .then(randomiseColours)
        .then(randomiseSomeColours)
        .then(printColours("Randomised"))
        .then(colours => compile(colours, background));
})
    .catch(e => {
    console.error(chalk_1.default.yellow("An error occurred", e));
    process.exit(1);
});
