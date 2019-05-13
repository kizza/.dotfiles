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

const input = () => process.argv.slice(2).pop() || defaultInput;

const formatColour = (colour) =>
  colour
    .replace('#', '')
    .match(/.{1,2}/g)
    .join('/')

const formatNumber = (number) => '00'.substring(0, 2 - number.toString().length) + number

module.exports = {
  input,
  formatColour,
  formatNumber
}

