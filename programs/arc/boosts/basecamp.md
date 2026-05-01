```css
body {
  background: linear-gradient(var(--color-body), #fff) no-repeat !important;
}

.chat-line--mention > .chat-line__bubble {
  background: rgb(252, 241, 223) !important;
}

/* Emma */
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

// Run on turbo load (ie. basecamp)
document.addEventListener("turbo:load", () => {
  sortTriageCards();
  enlargeTriageOnEnter();
})
```
