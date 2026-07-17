---
name: research
description: Use when you need current external facts. Fan out searches across the configured MCP servers, read sources, and verify before stating conclusions.
user-invocable: true
allowed-tools:
  - web_search
  - web_fetch
---
# Research

Smaller models hallucinate facts and APIs. Do not answer from memory when the
answer is checkable. Instead:

1. Search with the available tools (context7 for library docs, fetch for a known
   URL, tavily or web_search for open questions).
2. Read at least two independent sources for any non trivial claim.
3. Quote the source and prefer primary documentation over blog posts.
4. State clearly what you verified and what stays uncertain.

When a claim cannot be verified, say so rather than guessing.
