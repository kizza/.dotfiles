var [rootElement, navElement] = document.querySelectorAll("html, .topnav");
if (rootElement.style.fontSize === "16px") {
  navElement.style.display = "";
  rootElement.style.fontSize = "";
} else {
  navElement.style.display = "none";
  rootElement.style.fontSize =
    rootElement.style.fontSize === "" ? "32px" : "16px";
}
