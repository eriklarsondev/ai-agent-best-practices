# Writing an AGENTS.md

**Open when:** authoring or trimming the `AGENTS.md` for a repo.
**Skip if:** you're working in a repo, not shaping one.

Start from [`../templates/AGENTS.md`](../templates/AGENTS.md).

## The economics

This file is loaded on **every turn of every session, forever**. A long one costs more over a
month than every file an agent will ever read. Keep it to **one page** — if it doesn't fit on
a screen, it's carrying something that belongs in a leaf.

It earns that cost by preventing wrong guesses. One line that stops an agent running a
12-minute suite, or inventing a helper that already exists, pays for the whole file.

## The inclusion test

> Would an agent get this wrong, or get it right expensively, without the line?

**Include** — things that can't be cheaply inferred:

- The **test-one-file command**. The highest-value line in the file.
- Env vars or services required to boot, and the one command that boots it.
- Directories that are generated and must not be edited.
- A convention that contradicts what the code appears to do, and why.
- Genuinely surprising gotchas: the flaky suite, the 9-minute build, the migration that must
  run first.
- Standing permissions, if any — "commit as you go on feature branches" — since the default
  is to ask. See [`../boundaries.md`](../boundaries.md).

**Leave out** — anything two neighbouring files already demonstrate:

- Naming conventions, import style, formatting. The linter and the code say it better.
- A directory tour that `rg --files -d 2` produces for free.
- Generic advice ("write tests," "handle errors"). It's noise in every session.
- Architecture essays. Put those in `docs/adr/` where they're read once, on demand.
- Anything that duplicates `README.md`. Link instead.

## Shape

Scannable beats prose. Tables and terse bullets, declaratives not paragraphs. An agent needs
to extract six facts, not follow an argument.

```markdown
## Stack
Node 22 · TypeScript · Postgres (Prisma) · pnpm

## Commands
| Task | Command |
| --- | --- |
| Test one file | `pnpm test -- path/to/file.test.ts` |
...

## Do not edit
`src/generated/**` — regenerate with `pnpm codegen`
```

## Keep it honest

A stale `AGENTS.md` is worse than none: agents trust it over the code and act on a command
that no longer exists. When you change a command or move a directory, update the file in the
same change.

## Grow it from observed waste

Don't write it speculatively. Give an agent a small real task, watch where it guessed wrong
or read expensively, and add exactly that. Two or three iterations produce a better file than
any amount of upfront writing, and it stays short because every line was earned.

## When it outgrows a page

Split, don't expand. Keep `AGENTS.md` as an index with explicit *open when* triggers, and move
detail into linked files — the structure this repo uses. Loaded-always stays tiny;
loaded-sometimes carries the depth.
