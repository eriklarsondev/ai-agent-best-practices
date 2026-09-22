# Search and read

**Open when:** before opening a file you haven't located precisely.
**Skip if:** you already know the file and the line range.

## The funnel

Never skip a rung. Each one costs ~10× less than the next.

1. **Which files?** `rg -l 'pattern'` — paths only.
2. **Which lines?** `rg -n 'pattern' path/` — add `-C2` only if the match alone is ambiguous.
3. **Which region?** Read with `offset`/`limit` around the hit.
4. **Whole file** — only if you're about to edit it broadly, or it's under ~150 lines.

Flags live in [`../reference/cheatsheet.md`](../reference/cheatsheet.md). The two that matter
most: `-F` for literal strings (error messages, especially), `-m N` to cap runaway output.

## Outline a large file without reading it

```sh
rg -n '^(export )?(async )?(class|function|const [A-Z]|def |func |impl |type |interface )' src/big.ts
```

You get a symbol map with line numbers for ~200 tokens instead of 25k. Read the one region
that matters. For Python, `rg -n '^\s*(class|def) '`; for Go, `rg -n '^func '`.

## Read the repo's own answers first

`AGENTS.md`, `CLAUDE.md`, `README`, `docs/adr/`, and `CONTRIBUTING` cost a few hundred tokens
and often answer in one line what costs 20k to infer from source. Check for them before
inferring conventions.

## Read the whole file when

- It's under ~150 lines.
- You're restructuring it, or your edits will be scattered through it.
- It's the interface/type file that defines the contract you're implementing.

Otherwise, regions.

## Never read

Lockfiles · `node_modules/`, `vendor/`, `.venv/` · `dist/`, `build/`, `out/`, `target/` ·
`*.min.js`, source maps · `__snapshots__/` · binary or base64 assets · generated clients and
protobuf output · migrations you aren't modifying.

If you need one fact from one of these, extract it: `jq -r`, `rg -m1`, `head -3`.

## Answer shape before you search

State the question first — "which module registers the auth middleware?" — then pick the
search that answers exactly that. A search you can't attach a question to is a read you don't
need.
