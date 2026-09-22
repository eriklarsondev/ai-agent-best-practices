# Consistency with the codebase

**Open when:** writing code in a repo you didn't write.
**Skip if:** you've already read the neighbours.

## The rule

**If a pattern exists, follow it.** Even if you'd have done it differently. Even if the
existing way is mildly worse. A codebase where every module is individually optimal and
collectively inconsistent is harder to work in than one that's uniformly second-best —
and the inconsistency is permanent, while your preference was momentary.

The surrounding code is the specification. Reading two neighbours costs ~3k tokens and
settles more questions than any style guide.

## Find the pattern before you write

```sh
ls src/api/                                  # how are siblings named
rg -n 'export (async )?function' src/api/users.ts -m5   # shape of a sibling
rg -n 'throw new|raise ' src/api/ -m5        # how do errors work here
rg --files -g '**/*{test,spec}*' | rg users  # where and how are tests laid out
```

Then read the single closest sibling end to end. One file usually answers all of it.

## What "pattern" covers

| Dimension | Question the neighbours answer |
| --- | --- |
| Naming | `getUser` or `fetchUser` or `userGet`? `snake_case.py` or `kebab-case.ts`? |
| File layout | One export per file, or grouped? Where do types live? |
| Error handling | Throw, return a Result, return null? Which error class? |
| Validation | At the edge, per-layer, or with a shared schema helper? |
| Async style | Promises, async/await, callbacks? How are they cancelled? |
| Data access | Direct queries, repository, ORM? Where do transactions start? |
| Logging | Which logger, what level, what structured fields? |
| Config | Env vars read where — at module load, or injected? |
| Tests | Unit or integration? Fixtures or factories? Mocking style? |
| Comments | Density and format — see [`comments.md`](comments.md) |
| Imports | Absolute or relative? Barrel files or direct? Ordering? |

## When to deviate

Rarely, and never silently. Deviation is warranted only when:

- The existing pattern is **actually broken** for your case — a security hole, a real bug,
  a pattern that can't express what you need.
- The repo is **mid-migration** and the newer pattern is clearly the intended direction.
  Check: `git --no-pager log --oneline -10 -- src/api/` shows which way it's moving.
- The developer **asked** you to do it differently.

In all three, say so in your response in one sentence. A deviation the reviewer has to
discover is a bad surprise; one you named is a decision.

## What not to do about inconsistency you find

Don't "fix" it. If the repo has two competing patterns, pick the one used by the code nearest
your change — not the one you prefer, and not a third one that harmonizes them. Note the
divergence in a sentence if it matters; leave the cleanup to someone who can decide it.

Refactoring adjacent code to match your taste is scope creep, and it buries the change the
developer actually wanted. See [`code-restraint.md`](code-restraint.md).

## Tooling is part of the pattern

Never match style by eye when a tool already decides it. Detecting the formatter, running it
on the right scope, and what to do when the repo has none: [`formatting.md`](formatting.md).
