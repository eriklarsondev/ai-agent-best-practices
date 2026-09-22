# Workflow: adding a feature

**Open when:** implementing something new.
**Skip if:** it's a one-line change.

## 1. Find the precedent

Almost nothing is the first of its kind in a repo. Find the nearest existing thing and follow
it — cheaper than designing, and it produces code that matches.

```sh
rg --files -g '**/routes/**' -g '**/handlers/**'      # where do siblings live
rg -n 'router\.(get|post)\(' src/ -m1                  # how is one registered
rg --files -g '**/*{test,spec}*' | rg -i 'route'       # how is one tested
```

Read the closest sibling end to end. That single file usually answers: layout, naming, error
handling, validation, auth, logging, and test shape.

## 2. Trace the full path before writing

List the layers the change touches — route → handler → service → model → migration → types →
test → docs — and confirm each with a grep, not a read. Missing a layer is the most common
"almost done" failure, and it's far cheaper to find now.

## 3. Build the vertical slice first

One end-to-end path working beats four half-built layers. It gives you something to verify
against at every later step.

## 4. Implement

- New files go where siblings live, named the way siblings are named.
- Match the surrounding error handling and validation. If every handler validates input with
  the same helper, use it — don't hand-roll.
- No new dependency without asking. See [`../boundaries.md`](../boundaries.md).
- **A new server-side endpoint requires two things**, neither optional nor deferred: its own
  test file at the mirrored path
  ([`../practices/test-organization.md`](../practices/test-organization.md)), and an explicit
  authorization check ([`../practices/secure-coding.md`](../practices/secure-coding.md)).
  Before you call it done, state who may call it, what's validated, and what it leaks.

## 5. Check statically, then hand the run over

Compile/typecheck, lint the files you touched, and `rg -n 'name\('` every signature you
changed. That's your side — see
[`../practices/verification.md`](../practices/verification.md).

Cover the edges in the tests you wrote rather than by running anything: empty input, auth
failure, the error branch you added. Those are exactly the paths a happy-path manual check
misses, so they're worth more in a test file than in a click-through.

## 6. Report

What you built, where (`file:line` for the entry point), what you verified, what you assumed.
State any layer you deliberately left out — a missing migration or doc update reported is
fine; discovered later is not.

## Scope discipline

Build what was asked — not a narrowed version, not a generalized framework for the version
they might want next. Abstractions invented ahead of a second use case are a cost with no
payer. If part of the scope turns out to be blocked, finish everything else and say plainly
what you left and why.
