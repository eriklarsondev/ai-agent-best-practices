# Context budget

**Open when:** the task spans many files, or the transcript is getting long.
**Skip if:** it's a single-file change.

## There's no number to hit

Don't track a budget, don't allocate percentages, and don't stop mid-task to work out what a
turn cost. Accounting is its own kind of waste, and it makes you hesitant exactly where you
should be decisive. Work the task — the rules here are behavioral, and following them is the
whole discipline.

One fact is worth holding, because it's the reason the rules point where they do: a token you
*generated* — a command you ran, a file you opened, a subagent you spawned — is billed once
at full price and again on every turn that carries it afterwards. Caching makes re-sent
context cheap; it never makes a wasted read free. The cheapest move is the one you didn't
make.

Caching does impose one structural rule: **append, don't rewrite**. Reordering or editing
earlier context invalidates the cache from that point on. Add at the end.

## When discovery is running long

You'll notice it well before you could measure it: three files read and nothing changed yet, a
plan growing faster than the change it plans, the same file opened twice. The answer is never
more reading — it's a sharper grep, a state file on disk, or a question for the developer.

## Put long-lived state on disk, not in context

For multi-file migrations, audits, or anything spanning many turns, keep a checklist file:

```
scratch/migration.md
  - [x] src/auth/login.ts   — done, 3 call sites updated
  - [ ] src/auth/refresh.ts — blocked: needs the new token type first
  - [ ] src/api/session.ts
```

Three reasons: it survives context compaction, re-reading it is far cheaper than re-deriving
it, and the user can see the state. Update it as you go; don't reconstruct progress from the
transcript.

## Progressive disclosure

Structure knowledge so the entry point is tiny and the detail is one hop away with an explicit
trigger — the shape this repo uses. Applies to your own docs, your own subagent prompts, and
any `AGENTS.md` you write.

The test: can an agent decide *whether to open* a file from its index line alone? If it has to
open the file to find out, the index is doing no work.

## You are burning context if…

- You've read three files and changed nothing.
- You're opening a file you already opened.
- A command's output is longer than the conclusion you'll draw from it.
- You're about to run something — a checker, a build, a server, a browser — to grade your own
  work. That's the developer's two seconds and your five figures.
- You're re-explaining a decision the developer already made.
- You're writing a plan longer than the work it plans.

## Signals you should reset rather than push on

- You're re-reading files you read 20 turns ago because you no longer recall them.
- Your plan has drifted and you can't state the current goal in one sentence.
- Output quality is dropping: repeated edits to the same lines, contradictory claims.

Write the state to disk, summarize what's established, and continue from there.

## Don't re-derive

Facts established in the conversation stay established: paths, schemas, versions, the user's
choices. Re-grepping something you already found is pure waste — and re-litigating a decision
the user already made is worse than waste.
