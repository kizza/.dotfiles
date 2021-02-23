Array.from(document.querySelectorAll("a[href*='/commits/']"))
  .map(link => link.attributes["href"].value)
  .reduce(
    (acc, href) => (acc.indexOf(href) === -1 ? acc.concat([href]) : acc),
    []
  )
  .forEach(href => window.open(href));
