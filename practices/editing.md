# Editing

**Open when:** about to change existing code — the mechanics of making the edit small and
safe.
**Skip if:** you're creating a new file in a pattern you've already matched.

Three companions, each owning a slice this file doesn't repeat:
[`consistency.md`](consistency.md) (match the existing pattern) ·
[`code-restraint.md`](code-restraint.md) (write less) ·
[`comments.md`](comments.md) (comment policy).

## Before the first write

0. **Check where you are.** `git status --short && git branch --show-current`. Uncommitted
   changes you didn't make, or `main` when the task implies a branch — say so before editing.
1. **Does it already exist?** `rg -n 'thingYouAreAboutToWrite'`. Duplicates drift.
2. **What does the neighbour look like?** Read the closest sibling file — it settles naming,
   error handling, validation, and test shape in one read.
3. **What will this reach?** If you're changing a signature or a shared type,
   `rg -n 'name\('` now, not after the tests fail.

## Make the edit small

- Replace the **smallest string that is unique**. Include just enough surrounding context to
  disambiguate — no more.
- One concern per edit. No drive-by renames, reorders, or reformatting of lines you aren't
  changing: it doubles the token cost (write, then review) and buries the real change.
- Rewriting a whole file is for genuinely replacing it. Three-line changes are three-line
  edits.
- Don't reformat untouched lines and don't run the formatter — match the file's style; their
  pre-commit hook normalizes it ([`formatting.md`](formatting.md)).

## Don'ts that cost tokens and trust

| Don't | Why |
| --- | --- |
| Re-read the file to confirm the write | The edit tool errors loudly on failure; the read buys nothing |
| Leave `TODO`s or placeholder bodies unless asked | Unfinished work reported as finished is the worst failure mode |
| Introduce a dependency without asking | Out of bounds — [`../boundaries.md`](../boundaries.md) |
| Swallow an error to make a test pass | Fix the cause or report the blocker |
| Weaken a type or add `@ts-ignore` to get green | Same — it's a false report |
| Change a public signature silently | Grep the call sites and say what moved |
| Fix adjacent problems you weren't asked about | One sentence in your response instead |

## Keep the docs that describe it true

You don't write documentation unasked ([`code-restraint.md`](code-restraint.md)) — but when
your change makes an existing doc wrong, updating it isn't new documentation, it's part of
the change. A stale doc is worse than no doc: the next reader trusts it.

### The root README, specifically

**Update it whenever your change alters how someone sets up or runs the project.** That file
is the first thing a new developer follows and the last thing anyone remembers to update.
Triggers:

- A new env var or config value needed to boot — [`config-changes.md`](config-changes.md)
- A new dependency, service, or install step — database, queue, cache, worker
- A changed dev, build, or test command; a changed port
- A new setup step: migrations to run first, seed data, a codegen pass
- A raised minimum runtime version
- An architecture or entry-point change that makes the existing description wrong

**Not** triggers: internal refactors, bug fixes, or a new endpoint that needs no new setup.

The test: **would someone following the README today end up with a broken checkout?** If
yes, it's part of your change, not a follow-up.

### Everything else

```sh
rg -n 'oldFlagName|old_endpoint_path' -g '*.md' -g '*.rst' -g '*.txt'
```

Catches API docs, the repo's own `AGENTS.md` if you changed a command, and any ADR whose
decision you just reversed. Update the lines that are now false; don't expand beyond them.

## New files

- Put it where its siblings live; don't invent a directory for one file.
- Match the sibling naming convention — one `ls` of the directory settles it.
- Add the test alongside, in the layout the repo already uses.

## Scope

Implement what was asked — not a narrowed version, not an expanded one. If part of the scope
turns out to be blocked, finish everything else and say plainly what you left out and why.
Scaling the task down is the developer's call, not yours.

## When you're done

Leave the tree clean and hand off — [`handoff.md`](handoff.md). Don't run the app; don't
stage or commit.
