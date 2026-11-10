---
name: wiki-query
description: Answer a question from the LLM Wiki in docs/second-brain, citing wiki pages. Use when the user writes "query: <question>" or asks what the wiki says about a topic.
---

Query the LLM Wiki and synthesize an answer.

First read docs/second-brain/SCHEMA.md — it defines the wiki's layout, page formats, naming conventions and workflows, and is not loaded automatically.

Input: the question given by the user, e.g. `What are the main themes across all sources?`. If no question was given, ask for one.

Follow the Query Workflow defined in docs/second-brain/SCHEMA.md:
1. Read docs/second-brain/wiki/index.md to identify the most relevant pages
2. Read those pages (up to ~10 most relevant)
3. Synthesize a thorough markdown answer with [[PageName]] wikilink citations
4. Include a ## Sources section at the end listing pages you drew from
5. Ask the user if they want the answer saved as docs/second-brain/wiki/syntheses/<slug>.md

If the wiki is empty, say so and suggest ingesting a source first (wiki-ingest).

---

Provenance: adapted from the wiki workflows of https://github.com/SamurAIGPT/llm-wiki-agent, Copyright (c) 2023 SamurAIGPT, MIT License (full text in this repository's `LICENSE`). This note is not an instruction.
