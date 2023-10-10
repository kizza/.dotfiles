"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const build_1 = __importDefault(require("./build"));
const funs_1 = require("./funs");
const { color, foreground, background } = JSON.parse(funs_1.input());
build_1.default(color, foreground, background);
