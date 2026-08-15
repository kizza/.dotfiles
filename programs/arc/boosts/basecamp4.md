```css
body {
  background: linear-gradient(var(--color-body), #fff) no-repeat !important;
}

.chat-line--mention > .chat-line__bubble {
  background: rgb(252, 241, 223) !important;
}

/* Home page */

.home__layout {
  grid-template-columns: 3fr 1fr !important;
  grid-template-rows: min-content 1fr;
}
.home-menu {
  grid-row: 1; grid-column: 1;
}
.home__sidebar {
  grid-row: 2; grid-column: 2;
  text-align: left !important;
  margin: 6rem 0 0 !important;
}
.home__sidebar-right {
  grid-row: 1; grid-column: 2;
  margin-block-start: 4rem !important;
  margin-inline: 0 !important;
}

.home-menu {
  border: solid 0.25rem rgba(214, 228, 204, 0.582) !important;
  max-inline-size: auto;
  grid-column: 1;
  grid-row: 1 / span 2;
  max-block-size: 100vw !important;
  max-inline-size: 100vw !important;
  inline-size: 90% !important;
}
.home-mednu__scroller {
  width2: 60vw !important;
}

.card-grid--home {
  --card-column-count: 2 !important;
  --card-min-size: 1rem !important;
  grid-template-columns: repeat(4, 1fr) !important;
  height: 100%;
}
.card--project, .card--stack {
  --cdard-aspect-ratio: 1/1 !important;
}

/* Typography */
html {
  --text-body: 1.7rem !important;
  ---text-base: 1.7rem !important;
  ---text-12: 1.5rem !important;
  --16px: 1.6rem !important;
}
.perma-header__title {
  font-weight: bold !important;
}
.dock-card__title {
  color: var(--color-green-70) !important;
}

/* Ring one person's messages */
.chat-line[data-creator-id="19628647"] .chat-line__avatar img {
  border: solid 3px purple !important;
}
.chat-line[data-creator-id="19628647"] > .chat-line__bubble {
  border: solid  1px purple;
}

/* Needle move */
#new_gauge_needle {
  .trix-contained-input, .formatted_content, [data-controller="language-picker"] {
    min-height: 49vh !important;
  }
  [data-controller="language-picker"] {
    border: solid 2px gold; /* Show that it's working */
  }
}

/* Expand kanban triage */
.kanban-triage.hover .kanban-triage__cards {
  min-height: max-content !important;
}
```

```js
const getCardPriority = (card) => {
  // There is a "shadow" card element to skip
  if (card.classList.contains('kanban-card--shadowcard')) return 999;

  const title = card.querySelector('.kanban-card__title').title
  const prefix = title.substring(0, 2)
  switch (prefix) {
    case "P1": return 1;
    case "P2": return 2;
    case "P3": return 3;
    case "P4": return 4;
    default: return 99;
  }
}

const getCardCreation = (card) => {
  // There is a "shadow" card element to skip
  if (card.classList.contains('kanban-card--shadowcard')) return 999;

  const time = card.querySelector('time').getAttribute('datetime')
  return Date.parse(time);
}

// Reorder the triage cards in the dom
const sortTriageCards = () => {
  const triageCards = document.querySelector('.kanban-triage__cards');
  if (!triageCards) return;
  const items = Array.from(triageCards.children);

  // Sort by priority
  items.sort((a, b) => {
    const priorityDelta = getCardPriority(a) - getCardPriority(b);
    if (priorityDelta !== 0) return priorityDelta;
    return getCardCreation(a) - getCardCreation(b);
  });

  // Reorder in DOM
  items.forEach(item => triageCards.appendChild(item)); 
}

// Apply a .hover class to triage when hovered
const enlargeTriageOnEnter = () => {
  const triage = document.querySelector('.kanban-triage')
  if (!triage || triage.dataset.enlargeListenersBound === "true") return;

  triage.addEventListener('mouseenter', function () {
     triage.classList.add('hover')
  })
  triage.addEventListener('mouseleave', function () {
    triage.classList.remove('hover')
  })

  triage.dataset.enlargeListenersBound = "true";
}

const addTriageButton = () => { 
  // Avoid duplicates
  if (document.querySelector(".arc-open-triage-btn")) return;

  // Attach to the first kanban title
  const title = document.querySelector(".kanban-people");
  if (!title) return;

  const button = document.createElement("a");
  button.className = "btn btn--small btn--secondary btn--with-icon btn--edit-icon arc-open-triage-btn";
  button.href = "#";
  button.textContent = "Triage cards";
  button.style.marginLeft = "8px";

  button.addEventListener("click", (e) => {
    e.preventDefault();

    const links = [
      ...document.querySelectorAll(
        ".kanban-triage__cards a.kanban-card__link"
      ),
    ];

    const uniqueUrls = [
      ...new Set(
        links.map((link) =>
          new URL(link.getAttribute("href"), window.location.origin).href
        )
      ),
    ];

    const openUrls = uniqueUrls.slice(0, 10);
    openUrls.forEach((url, index) => {
      // window.open(url, "_blank");
      const a = document.createElement("a");
      a.href = url;
      a.target = "_blank";
      a.rel = "noopener noreferrer";

      // Required for Firefox/WebKit sometimes
      document.body.appendChild(a);

      a.click();

      a.remove();
    });

    console.log(`Opened ${openUrls.length} triage cards`);
  });

  title.appendChild(button);
}

// Run on turbo load (ie. basecamp)
document.addEventListener("turbo:load", () => {
  sortTriageCards();
  enlargeTriageOnEnter();
  addTriageButton();
})
```
