---
name: miro-dump
description: Convert messy notes, research, summaries, transcripts, plans, or brainstorms into a Miro-ready CSV of sticky notes with semantic colours, tags, grouping fields, and import instructions.
---

# Miro Dump Skill

When the user says things like:

- "put this into a miro format"
- "turn this into Miro stickies"
- "make this Miro-ready"
- "format this for a Miro board"
- "convert this into post-it notes"

create a CSV file suitable for importing into Miro as sticky notes.

## Goal

Transform unstructured or semi-structured content into atomic, useful sticky notes for sense-making in Miro.

Each row should represent one sticky note.

## Output file

Create a CSV file in the current working directory.

Use a descriptive filename based on the source content, for example:

- `miro_customer_interviews.csv`
- `miro_strategy_notes.csv`
- `miro_retro_feedback.csv`
- `miro_research_findings.csv`

Use lowercase, hyphen or underscore separated names. Prefer `.csv`.

## CSV columns

Use this schema unless the user asks otherwise:

```csv
note,theme,cluster,type,priority,colour,tags,source
