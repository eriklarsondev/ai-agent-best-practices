# Handoff

**Open when:** the change is made and your static checks are done — **what** goes in the
final message.
**Skip if:** the task was a question, not a change.

Third in the end-of-task chain: [`verification.md`](verification.md) (what to check) →
**handoff** (what to say) → [`communication.md`](communication.md) (how to write it).

## The model

You make the change, write the tests, and prove it compiles. **The developer runs it, tests
it, stages it, commits it, and pushes it.** That division is deliberate: they're faster at
judging whether it's right, and an independent runner is what makes a green test mean
something.

Your last message is the interface between those halves. It should take about thirty seconds
to read and leave nothing to figure out.

## What the handoff contains

1. **What changed** — one line, plus `file:line` for the entry point. Not the diff.
2. **What you checked** — the static checks you actually ran, with results.
   `mypy auth/ → clean`.
3. **What you wrote but didn't run** — the test files, with the exact command to run them.
   Never phrase these so they sound like they passed.
4. **What they should exercise by hand** — the specific paths you couldn't check. This is
   the part only you can supply; you know where the risk is.
5. **Assumptions** — one line each, so a wrong one is cheap to correct.
6. **What you left out** — anything blocked or deliberately out of scope.
7. **The commands they'll want next** — exact, copy-pasteable.

## Shape

> Refresh tokens now rotate on use — `auth/refresh.py:34`. Revocation moved ahead of the
> expiry check so a replayed token fails closed.
>
> Checked: `mypy auth/ → clean`, `ruff check auth/ → clean`, and `rg -n 'refresh_token\('`
> confirms all 4 call sites updated.
>
> Wrote `tests/auth/test_refresh.py` — 3 cases: rotation, replay rejection, expiry. I didn't
> run them.
>
> Worth exercising: log in on two devices, then refresh on the older one — that session should
> be signed out. I also didn't touch the mobile client's retry path; it may need the same fix.
>
> Assumed the 30-day refresh window is unchanged; nothing in the issue said otherwise.
>
> ```sh
> pytest tests/auth/test_refresh.py -q
> git add auth/refresh.py tests/auth/test_refresh.py
> git commit -m "fix: rotate refresh tokens on use"
> ```

## "Worth exercising" is the highest-value line

You know which branch the test stubs out, which integration you touched but never exercised,
which screen re-renders on the changed state. Naming two or three specific things beats
"please test it."

**For UI changes this is the whole handoff.** Never drive a browser yourself — no Playwright,
no Puppeteer, no screenshot loops. Instead, hand over a click path precise enough that they
don't have to reconstruct it:

> Worth clicking through: Settings → Billing with an expired card on file. The error banner
> is new, and the retry button should stay disabled until the form re-validates. Also check it
> at narrow width — the banner shares a row with the plan selector.

Be specific about the path: *"log in on two devices, refresh on the older one"*, not
*"test authentication"*.

## Leave the tree clean

```sh
git status --short
```

Nothing in there you didn't intend: no debug logging, no `.bak` files, no scratch scripts.
Stage nothing, commit nothing, push nothing — see [`../boundaries.md`](../boundaries.md).

## Don't

- Don't paste the diff. They have it.
- Don't narrate the tool calls. They watched.
- **Don't write the summary to a file.** No `CHANGES.md`, no `SUMMARY.md` — this message *is*
  the deliverable ([`code-restraint.md`](code-restraint.md)).
- Don't say "tests added and passing" when you didn't run them.
- Don't claim it works when you verified it compiles.
- Don't end with three offers of further work. One, if there's a real fork.
- Don't commit "to save them a step." That step is theirs.
