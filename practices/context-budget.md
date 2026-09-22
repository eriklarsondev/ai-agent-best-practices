# Context budget

**Open when:** the task spans many files, or the transcript is getting long.
**Skip if:** it's a single-file change.

## Dollars vs. window

| | Prompt caching helps? | Degrades your output? |
| --- | --- | --- |
| Dollar cost of re-sent tokens | Yes, a lot | No |
| Context window occupancy | **No** | **Yes** |

A cached 40k-token file still occupies 40k tokens of working set. Optimize the window; the
dollars mostly take care of themselves.

Caching does impose one structural rule: **append, don't rewrite**. Reordering or editing
earlier context invalidates the cache from that point on. Add at the end.

## A rough allocation

For a task of any size, aim to spend:

- **≤ 30% on discovery** (search, read, orient). Past that, you're exploring, not working.
- **~40% on the work itself** (edits, reasoning, verification output).
- **≥ 30% held in reserve.** Quality falls off well before the window is full; leave room for
  the failure you haven't hit yet.

If discovery is blowing past 30%, the answer is almost always delegation
(see [`delegation.md`](delegation.md)) or a state file, not more reading.

## Put long-lived state on disk, not in context

For multi-file migrations, audits, or anything spanning many turns, keep a checklist file:

```
scratch/migration.md
  - [x] src/auth/login.ts   — done, 3 call sites updated
  - [ ] src/auth/refresh.ts — blocked: needs the new token type first
  - [ ] src/api/session.ts
```

Three reasons: it survives context compaction, it costs ~200 tokens to re-read instead of
re-deriving, and the user can see the state. Update it as you go; don't reconstruct progress
from the transcript.

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
- You're about to start a server or a browser to check your own work.
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
