var result = Array.from(
  document.querySelectorAll("td.blob-code-addition")
).reduce((all, line) => {
  var more = Array.from(line.querySelectorAll(".x")).reduce((acc, each) => {
    return acc + each.innerText;
  }, "");
  return all.concat(more);
}, []);
result.sort().forEach(e => console.log(e));
