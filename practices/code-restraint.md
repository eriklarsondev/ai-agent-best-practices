# Code restraint

**Open when:** you're about to add a file, an abstraction, a dependency, or more than ~50
lines.
**Skip if:** you're deleting code.

## The default

**The smallest change that fully does the job.** Not the most general, not the most
future-proof, not the most impressively structured. Every line you add is a line someone
maintains, reviews, and reads for years — and a line every future agent pays to load.

Volume is not effort. A 30-line diff that solves the problem beats a 600-line one that solves
it and four problems nobody has.

## Reuse before you write

```sh
rg -n 'formatCurrency|format_currency'        # does the helper already exist
rg --files -g '**/utils*' -g '**/lib/**'      # where would it live
rg -n '"lodash"|"date-fns"' package.json      # is it already a dependency
```

Two minutes of grep beats a duplicate implementation that drifts from the original.

## Don't add

| Don't | Instead |
| --- | --- |
| An abstraction for one call site | Write it inline. Abstract at the second or third use, when you know the shape |
| Config options nobody requested | Hardcode it; make it configurable when someone asks |
| A dependency to avoid ~20 lines | Write the 20 lines |
| Scaffolding you didn't need | Delete what the generator produced and you don't use |
| A new folder for one file | Put it with its siblings |
| `index.ts` re-export barrels | They hide structure and slow tooling; import directly |
| Interfaces with one implementation | Use the concrete type until there's a second |
| Speculative `export`s | Keep it private until something outside needs it |
| Commented-out old code | Delete it. Git has it |
| `README.md`, `NOTES.md`, `CHANGELOG.md` unasked | Say it in your response instead — see below |
| Defensive null checks for impossible nulls | Let it throw; guard at the trust boundary only |
| Validation repeated at three layers | Validate once, at the edge |
| `try`/`catch` that logs and rethrows | Remove it; handle where you can actually act |

## Never write a file to explain your own work

After finishing a change, the pull is to write `CHANGES.md`, `SUMMARY.md`,
`IMPLEMENTATION_NOTES.md`, `MIGRATION_GUIDE.md`, or `REFACTOR_PLAN.md`. Don't. Not one of
them, not "just a short one."

- **Audience of zero.** The developer just watched you do the work. The summary belongs in
  your response ([`handoff.md`](handoff.md)) and, if it merges, the commit message and PR
  description — where people actually look.
- **Stale on the next commit**, permanently, with nobody aware it needs deleting.
- **It pollutes future context.** Every agent after you reads a description of a moment that
  no longer exists.

What's legitimate instead:

| Write | When |
| --- | --- |
| A doc the developer asked for | They asked |
| An edit to the **root README** | Your change altered setup or run steps — [`editing.md`](editing.md) |
| An edit to any other existing doc | Your change made it wrong |
| An ADR | A real decision was made *and* the repo already uses ADRs |
| A checklist in a scratch dir **outside the repo** | Multi-session state — [`context-budget.md`](context-budget.md) |

**The litmus test:** would someone unfamiliar with this change need the file six months from
now? A file describing *how the system works* can earn its place. A file describing *what you
did* never does — that's what the diff, the commit, and your message are for.

## Comments

Same principle, same discipline: the cheapest comment is the one you don't write. Full policy
in [`comments.md`](comments.md).

## Leave nothing behind

Before you report done:

```sh
git status --short        # anything here you didn't intend?
```

Remove debug logging you added, temporary scripts, `.bak`/`.orig` files, commented-out
experiments, unused imports, and scratch notes. Put genuinely temporary work in a scratch
directory outside the repo, not in the tree.

## Prefer deleting

A change that removes code is usually better than one that adds. If you can solve it by
deleting a branch, collapsing a wrapper, or removing a now-dead path, do that — and say so.

## The honest signal

If the change feels too small for the request, that's usually correct. Reach for restraint
before you reach for thoroughness-by-volume: the extra code is the easiest thing to add and
the hardest thing to ever remove.
