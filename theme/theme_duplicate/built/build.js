"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.saveTheme = void 0;
const chroma_js_1 = __importDefault(require("chroma-js"));
const fs_1 = __importDefault(require("fs"));
const funs_1 = require("./funs");
const { assign, keys } = Object;
exports.default = (color, foreground, background) => {
    const hex = Array.from(color.keys()).reduce((acc, i) => assign({}, acc, {
        [`COLOUR_${funs_1.formatNumber(i)}`]: color[i]
    }), {
        NORMAL_FOREGROUND: foreground,
        NORMAL_BACKGROUND: background,
        COLOUR_21: chroma_js_1.default(foreground) // Lighter forground
            .brighten(0.1)
            .toString(),
        COLOUR_20: chroma_js_1.default(foreground) // Lighter forground
            .darken(0.1)
            .toString(),
        COLOUR_18: chroma_js_1.default(background) // Lighter background
            .brighten(0.2)
            .toString(),
        COLOUR_19: chroma_js_1.default(background) // Selection background
            .brighten(0.3)
            .toString()
    });
    const additional = funs_1.randomiseArray(color).map(x => chroma_js_1.default(x).saturate(1));
    // const additional: Colour[] = chroma
    //   .scale(color)
    //   .mode("lch")
    //   .colors(2)
    //   .map(x => chroma(x));
    hex["COLOUR_16"] = additional[0].toString();
    hex["COLOUR_17"] = additional[1].toString();
    exports.saveTheme(hex);
};
exports.saveTheme = (hex) => {
    const os = require("os");
    const colours = funs_1.mapValues(hex, funs_1.formatColour);
    fs_1.default.readFile("templates/shell.template.sh", "utf8", (_, buffer) => {
        console.log('saving', colours);
        const theme = keys(colours).reduce((acc, key) => acc.replace(new RegExp(key, "g"), colours[key]), buffer);
        // const themeName = "test"
        // const themePath = `${os.homedir()}/.config/base16-shell/scripts/base16-${themeName}.sh`
        // fs.writeFile(themePath, theme, "utf8", e => {
        fs_1.default.writeFile("dist/shell.theme.sh", theme, "utf8", e => {
            console.log(e || "Done");
        });
    });
};
