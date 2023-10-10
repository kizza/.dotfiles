"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.COLOUR_INFO = void 0;
const express_1 = __importDefault(require("express"));
const fs_1 = __importDefault(require("fs"));
const build_1 = require("./build");
const funs_1 = require("./funs");
const { assign, keys } = Object;
exports.COLOUR_INFO = {
    "00": "Base 00 - Black", "01": "Base 08 - Red", "02": "Base 0B - Green", "03": "Base 0A - Yellow", "04": "Base 0D - Blue", "05": "Base 0E - Magenta", "06": "Base 0C - Cyan", "07": "Base 05 - White", "08": "Base 03 - Bright Black", "09": "Base 08 - Bright Red", "10": "Base 0B - Bright Green", "11": "Base 0A - Bright Yellow", "12": "Base 0D - Bright Blue", "13": "Base 0E - Bright Magenta", "14": "Base 0C - Bright Cyan", "15": "Base 07 - Bright White", "16": "Base 09 - Integers, booleans, constants", "17": "Base 0F - Depreciated... open/close embeded language tags", "18": "Base 01 (lighter background)", "19": "Base 02 (selection background)", "20": "Base 04 (darkder foreground)", "21": "Base 06 (lighter foreground)"
};
const toJson = (text) => '{' + text.split("\\n")
    .filter(Boolean)
    .filter(each => each.indexOf("_") === -1)
    .map(each => each.trim())
    .map(pair => pair.split("="))
    .map(([key, value]) => [key, asColour(value)])
    .map(([key, value]) => `"${key}": "${value}"`)
    .join(", ") + '}';
const asColour = (text) => (text.indexOf("color") === 0) ? `$${text}` : `#${text}`;
const asInput = (name, value) => `<p class="cursor-pointer flex space-x-2"><label title="${exports.COLOUR_INFO[name.replace("color", "")]}">${name}</label><input type="text" name="${name}" value="${value}" class="coloris" /></p>`;
const asStyle = (name, value) => `
  .text-${name} { color: ${value} }
  .bg-${name} { background: ${value} }
`;
const ui = (colours) => {
    // const colours: Record<string, string> = JSON.parse(toJson(input()))
    const palette = keys(colours)
        .map(key => [key, colours[key]])
        .filter(([_name, value]) => value.indexOf("#") === 0);
    const inputs = palette
        .map(([name, value]) => asInput(name, value))
        .join("");
    const styles = `
    ${palette.map(([name, value]) => asStyle(name, value)).join("")}
    `;
    return fs_1.default
        .readFileSync('./templates/tweak.html', 'utf-8')
        .replace("{styles}", styles)
        .replace("{inputs}", inputs);
};
const initialColours = () => JSON.parse(toJson(funs_1.input()));
// Run the app
const app = express_1.default();
const PORT = 4000;
app.use(express_1.default.urlencoded({ extended: false }));
app.get("/", (_req, res) => res.send(ui(initialColours())));
app.post('/', (req, res) => {
    console.log(req.body);
    build_1.saveTheme(funs_1.mapKeys(req.body, (key) => key.replace("color", "COLOUR_")));
    res.send(ui(Object.assign(Object.assign({}, initialColours()), req.body)));
});
app.listen(PORT, () => console.log(`Listening on post ${PORT}`));
