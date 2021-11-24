# Theme Generator

## Build a theme from terminal.sexy

Easily build a `base16` theme from the [terminal.sezy](https://terminal.sexy/) website

1. Find a theme you like on [terminal.sezy](https://terminal.sexy/)
2. Export it as `JSON Scheme` (copy the output)
3. Run `bin/build '...'` (pasting in the json that was exported)

The resulting theme is loaded in, and persisted to the `/dist` folder

## Build a theme from a copied palette

(brew install pngpaste)
1. Build palette.js `yarn && yarn start``
2. Copy an image
3. run bin/palette (with the image in your clipboard)

```
bin/palette --darken 2
bin/palette --lighten 2
bin/palette --use 2 (uses in place)
bin/palette --pick 2 (uses and removes)
bin/palette --bg 99ccff (fixed background)
bin/palette --random 1 (true for random)
```
