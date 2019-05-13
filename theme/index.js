const Color = require('Color');
const fs = require('fs')
const { assign, keys } = Object
const { formatColour, formatNumber, input } = require('./funs');

const { color, foreground, background } = JSON.parse(input())

const hex = Array.from(color.keys()).reduce((acc, i) =>
  assign({}, acc, {
    [`COLOUR${formatNumber(i)}`]: color[i]
  }),
  {
    'NORMAL_FOREGROUND': foreground,
    'NORMAL_BACKGROUND': background,
    'LIGHTER_FOREGROUND': Color(foreground).lighten(0.1).hex(),
    'DARKER_FOREGROUND': Color(foreground).darken(0.1).hex(),
    'LIGHTER_BACKGROUND': Color(background).lighten(0.2).hex(),
    'SELECTION_BACKGROUND': Color(background).lighten(0.3).hex()
  }
)

const colours = keys(hex).reduce((acc, key) =>
  assign({}, acc, {
    [key]: formatColour(hex[key])
  }), {}
);

fs.readFile('templates/shell.template.sh', 'utf8', (_, buffer) => {
  const theme = keys(colours).reduce((acc, key) =>
    acc.replace(new RegExp(key, 'g'), colours[key]),
    buffer
  )

  fs.writeFile('dist/shell.theme.sh', theme, 'utf8', (e) => {
    console.log(e || 'Done')
  });
});
