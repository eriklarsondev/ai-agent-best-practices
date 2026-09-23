# Consistency with the codebase

**Open when:** writing code in a repo you didn't write.
**Skip if:** you've already read the neighbours.

## The rule

**If a pattern exists, follow it.** Even if you'd have done it differently. Even if the
existing way is mildly worse. A codebase where every module is individually optimal and
collectively inconsistent is harder to work in than one that's uniformly second-best —
and the inconsistency is permanent, while your preference was momentary.

This is a team rule before it's a taste rule. Everyone on the repo works to one standard, and
code written to a different one makes everybody else's habits wrong in one file that nobody
will ever be told about. You are not a special case for being fast.

## Precedence, when sources disagree

1. **What the developer just told you.**
2. **The written standard** — `AGENTS.md`, `CONTRIBUTING`, a style guide, `docs/adr/`.
3. **What the tooling enforces** — lint and formatter config is the standard, executable.
4. **The nearest code** — closest sibling, then the module, then the repo.
5. **Your own preference** — last, and only where 1–4 are all silent.

Reading two neighbours costs ~3k tokens and settles more questions than any style guide, but
it settles them *fourth*. Check for a written standard first; it's cheaper and it's binding.

## Never add a second way to do an existing thing

The most expensive thing an agent does to a codebase is introduce a competing pattern. It
breaks nothing, so nobody reverts it — and now the repo has two answers to one question, and
every future reader and agent has to learn both.

| If the repo already has | Don't add |
| --- | --- |
| An HTTP client wrapper | A raw `fetch` / `requests` call |
| A validation library or schema helper | Hand-rolled checks, or a second library |
| An error class hierarchy | A bare `throw new Error`, or a `Result` type |
| A date/time utility | A second one, or raw arithmetic |
| A logger with structured fields | `console.log` / `print` |
| A data-fetching or state pattern | A different one "just here" |
| A test factory or fixture style | A second style beside it |

Use the existing one, even when the existing one is worse. If it genuinely can't do what you
need, that's one sentence in your response — not a second implementation.

## Find the pattern before you write

```sh
ls src/api/                                             # how are siblings named
rg -n 'export (async )?function' src/api/users.ts -m5   # shape of a sibling
rg --files -g '**/*{test,spec}*' | rg users             # how are tests laid out
```

Then read the single closest sibling end to end. One file answers nearly all of it: naming,
file layout, error handling, validation, async style, data access, logging, config, test
shape, import ordering, and comment density ([`comments.md`](comments.md)).

## When to deviate

Rarely, and never silently. Deviation is warranted only when:

- The existing pattern is **actually broken** for your case — a security hole, a real bug,
  a pattern that can't express what you need.
- The repo is **mid-migration** and the newer pattern is clearly the intended direction.
  Check: `git --no-pager log --oneline -10 -- src/api/` shows which way it's moving.
- The developer **asked** you to do it differently.

In all three, say so in your response in one sentence. A deviation the reviewer has to
discover is a bad surprise; one you named is a decision.

The middle case is the one to be careful with on a team. "Which way are we migrating" is a
decision someone already made, and you're inferring it from ten commits. Follow the direction
the recent ones show, say that's what you did and why, and let them correct you.

## What not to do about inconsistency you find

Don't "fix" it. Two competing patterns already in the repo means picking the one nearest your
change — not the one you prefer, and not a third that harmonizes them. Note it in a sentence
if it matters; the cleanup belongs to whoever can decide it, and doing it here buries the
change they actually asked for ([`code-restraint.md`](code-restraint.md)).

## Tooling is part of the pattern

Never match style by eye when a tool already decides it. Detecting the formatter, running it
on the right scope, and what to do when the repo has none: [`formatting.md`](formatting.md).
