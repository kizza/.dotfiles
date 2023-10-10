import build from "./build";
import { input } from "./funs";

const { color, foreground, background } = JSON.parse(input());

build(color, foreground, background);
