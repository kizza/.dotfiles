const hrefs = [...document.querySelectorAll(".commit-message a")]
  .map(l => l.attributes["href"].value)
  .forEach(href => window.open(href));
