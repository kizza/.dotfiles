[...document.querySelectorAll("a[href*='/commits/']")]
  .map(link => link.attributes["href"].value)
  .reduce((acc, href) => ({
    ...acc,
    [href]: true
  }), {})
  .map(hrefs => Object.keys(hrefs))
  .forEach(href => console.log(href))
// .forEach(href => window.open(href));
