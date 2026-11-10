---
name: wiki-lint
description: Check the content quality of the LLM Wiki in docs/second-brain — orphan pages, broken wikilinks, missing entity pages, contradictions, stale summaries, data gaps. Use when the user says "lint" or asks to check the wiki for contradictions or broken links.
---

Check the LLM Wiki for content issues.

First read docs/second-brain/SCHEMA.md — it defines the wiki's layout, page formats, naming conventions and workflows, and is not loaded automatically.

Follow the Lint Workflow defined in docs/second-brain/SCHEMA.md. Pages are the .md files under docs/second-brain/wiki/.

Structural checks (search the files for [[wikilinks]]):
1. Orphan pages — wiki pages with no inbound [[wikilinks]] from other pages
2. Broken links — [[WikiLinks]] pointing to pages that don't exist
3. Missing entity pages — names referenced in 3+ pages but lacking their own page
4. Sparse pages — pages with fewer than 2 outbound [[wikilinks]]

Semantic checks (read and reason over page content):
5. Contradictions — claims that conflict between pages
6. Stale summaries — pages not updated after newer sources changed the picture
7. Data gaps — important questions the wiki can't answer; suggest specific sources to find

Output a structured markdown lint report. At the end, ask if the user wants it saved to docs/second-brain/reports/lint-YYYY-MM-DD.md (today's date; overwrite if it already exists).

Append to docs/second-brain/wiki/log.md: ## [today's date] lint | Wiki health check

---

Provenance: adapted from the wiki workflows of https://github.com/SamurAIGPT/llm-wiki-agent, Copyright (c) 2023 SamurAIGPT, MIT License (full text in this repository's `LICENSE`). This note is not an instruction.
