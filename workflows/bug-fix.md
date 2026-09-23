# Workflow: fixing a bug

**Open when:** starting a bug report or a failing test.
**Skip if:** you already have a repro and know the cause.

## 1. Locate the failure, then write the repro

```sh
rg -nF 'the exact error string the user pasted'
```

An error message is the single cheapest entry point into an unfamiliar codebase — a literal
grep (`-F`) usually lands you on the throwing line for ~100 tokens. Prefer it to reading.

Then **write** the smallest test that reproduces it, at the mirrored path
([`../practices/test-organization.md`](../practices/test-organization.md)). You don't run it
— hand the command to the developer, and ask them to confirm it fails *before* you fix, so
"fixed" means something afterward.

> Wrote a failing case at `tests/auth/test_refresh.py::test_replayed_token_rejected`. Worth
> running it before I touch anything — it should fail with `AssertionError: expected 401`.

This is the one place not running things genuinely costs you: without a confirmed red, your
fix is reasoned rather than demonstrated. Say so plainly rather than implying otherwise.

## 2. Localize with the stack trace, not with reading

Take the deepest frame in *your* code (skip framework frames), read that region with
`offset`/`limit`, and stop. Only widen if the cause clearly isn't there.

## 3. Find the cause before changing anything

| Question | Cheap move |
| --- | --- |
| When did this break? | `git --no-pager log --oneline -10 -- path/to/file.ts` |
| Who introduced this line? | `git --no-pager log -1 --format='%h %s' -L 40,50:path/file.ts` |
| Was this value ever validated? | `rg -n 'fieldName'` across the module |
| Is this the only call site? | `rg -n 'funcName\('` |

Fix the cause. Symptom patches — a null guard around something that should never be null, a
retry around a logic error — come back, and cost more the second time.

## 4. Change the minimum

Smallest unique replacement. No drive-by refactoring, no reformatting: a 4-line diff reviews
in seconds and makes the fix obvious. See [`../practices/editing.md`](../practices/editing.md).

## 5. Check by reading, then hand the repro back

Re-read the diff. If the fix changed a signature or a shared helper, `rg -n 'name\('` for
call sites — that catches what a single test wouldn't. Details in
[`../practices/verification.md`](../practices/verification.md).

Then hand over the same command from step 1. It should now go green, and they're the ones who
can confirm that:

> `pytest tests/auth/test_refresh.py::test_replayed_token_rejected -q` — red before, should
> pass now.

## 6. Report

Cause in one sentence, fix location as `file:line`, what you checked statically, and the
repro command for them to run. If the bug revealed a second problem you didn't fix, one
sentence on it — not a refactor proposal.

## Traps

- Fixing the test instead of the code.
- Widening a `try/except` until the error disappears.
- Reading the whole module because the trace was ambiguous — grep the symbol instead.
- Calling it fixed without asking them to re-run the repro.
