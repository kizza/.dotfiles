# Mermaid

Most Mermaid failures are silent: the parser gives up and the diagram renders as raw text, or a
label truncates and nobody notices. These are the rules that prevent it.

## Which diagram type

| Question the figure answers | Type |
|---|---|
| What happens, in what order, with branches | `flowchart TD` |
| Who calls whom, over time | `sequenceDiagram` |
| What are the tables and how do they relate | `erDiagram` |
| What states can this be in, and what moves it | `stateDiagram-v2` |
| What depends on what | `flowchart TD` with `subgraph` |

**`TD`, almost always.** `LR` spreads horizontally and Mermaid scales everything down to fit the
width, which is how you get unreadable 9px labels. Use `LR` only for a genuinely linear 3–4 node
pipeline.

**Max 10–12 nodes.** Past that, readability collapses even with zoom. For 15+ elements use the
hybrid pattern: a 5–8 node Mermaid overview of the module relationships, then CSS grid cards
carrying the detail. Never cram it all into one diagram.

## Syntax that silently breaks

**Quote any label containing punctuation.** Parentheses, colons, commas, brackets, ampersands, and
slashes all break the parser unquoted:

```
%% WRONG — the leading / starts parallelogram shape syntax
CMD[/gallery command] --> SRV[server]
%% RIGHT
CMD["/gallery command"] --> SRV[server]
A["handleRequest(ctx)"] --> B["DB: query users"]
```

**Line breaks are `<br/>`, never `\n`.** An escaped `\n` renders as the literal characters.

```
A["Copilot Backend<br/>/api + /api/voicebot"] --> B["Redis"]
```

**Keep IDs alphanumeric.** The readable name goes in the label, not the id: `userSvc["User Service"]`.

**Escape literal pipes** as `#124;`, or rephrase — pipes delimit edge labels.

**Sequence diagram messages cannot be quoted or escaped.** Braces, brackets, angle brackets and `&`
break the parser and the entire diagram renders as raw text. Write plain English, not code:

```
%% WRONG
A->>B: web_search({ queries: [...] })
%% RIGHT
A->>B: Call web_search with queries
```

**`stateDiagram-v2` has a stricter parser than flowcharts.** No `<br/>`, no parentheses in labels,
no second colon. If you need any of those, use a flowchart instead.

**Do not mix syntaxes.** `-->` is flowchart; sequence uses `->>`. `:::className` is flowchart only.

## Arrows carry meaning

| Arrow | Means |
|---|---|
| `-->` | Primary flow |
| `-.->` | Optional, async, or fallback |
| `==>` | Critical or highlighted path |
| `--x` | Blocked or rejected |
| `-->\|label\|` | Labelled — decision branches, what the edge carries |

Label every arrow that is not obvious. An unlabelled arrow claims only "related somehow", which is
what the reader already knew.

## Rendering

The scaffold has this wired already — do not reinvent it.

- `theme: 'base'` with `themeVariables` bound to the page palette. Never a stock Mermaid theme.
- `fontSize: '16px'`, bumped to 18–20px once a diagram passes ~10 nodes.
- `layout: 'elk'` (needs `@mermaid-js/layout-elk`; without it Mermaid silently falls back to dagre).
- Never a bare `<pre class="mermaid">`. Always `.diagram-shell` > `.mermaid-wrap` >
  `.zoom-controls` + `.mermaid-viewport` > `.mermaid-canvas`, with the source in
  `<script type="text/plain" class="diagram-source">` so several diagrams coexist without id
  collisions.
- Parse rendered SVG with `DOMParser(..., 'text/html')` and `adoptNode` it. The strict XML parser
  silently truncates labels, because Mermaid 10+ emits unclosed HTML like `<br>` inside
  `<foreignObject>`.
- Never define a page-level `.node` class — Mermaid uses it internally. Namespace page classes.
- Avoid opaque light fills like `fill:#fefce8`; they blow out as bright boxes in dark mode.
- Mermaid bakes colours into the SVG at render time, so a runtime palette swap must re-render every
  diagram — that is what `window.rerenderDiagrams()` is for.

## Wrap it

Every diagram sits in a `<figure>` with a `<figcaption>` stating its one claim, and `role="img"`
plus a matching `aria-label` on the shell wrapper — not on the SVG, which gets replaced on re-render.
