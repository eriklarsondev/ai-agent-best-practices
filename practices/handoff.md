# Handoff

**Open when:** the change is made and you've re-read and grepped it — **what** goes in the
final message.
**Skip if:** the task was a question, not a change.

Third in the end-of-task chain: [`verification.md`](verification.md) (what to check) →
**handoff** (what to say) → [`communication.md`](communication.md) (how to write it).

## The model

Your last message is the interface between the half you did and the half they do
([`running-things.md`](running-things.md)). It should take about thirty seconds to read and
leave nothing to figure out.

## What the handoff contains

1. **What changed** — one line, plus `file:line` for the entry point. Not the diff.
2. **What you checked** — the greps you ran and what they returned, and that you re-read the
   diff. `rg -n 'refresh_token\(' → 4 sites, all updated`.
3. **What you wrote but didn't run** — the test files. Never phrase these so they sound like
   they passed.
4. **What's most likely wrong** — your own ranked uncertainty, worst first. You didn't run the
   checker, so say where you expect it to complain and why.
5. **What they should exercise by hand** — the specific paths reading couldn't settle.
6. **Assumptions, and anything left out** — one line each, so a wrong one is cheap to correct.
7. **The commands they'll want next** — exact, copy-pasteable, cheapest failure first.

## Shape

> Refresh tokens now rotate on use — `auth/refresh.py:34`. Revocation moved ahead of the
> expiry check so a replayed token fails closed.
>
> Checked by reading: `rg -n 'refresh_token\('` → 4 call sites, all updated; nothing in
> `migrations/` references the field. I re-read the diff. I didn't run anything.
>
> Wrote `tests/auth/test_refresh.py` — 3 cases: rotation, replay rejection, expiry. Unrun.
>
> Most likely wrong: the `token_family` column I added to the model. I matched the shape at
> `auth/models.py:61`, but couldn't confirm the type against your migration tooling — `mypy`
> will say immediately if it's off.
>
> Worth exercising: log in on two devices, then refresh on the older one — that session should
> be signed out. I didn't touch the mobile client's retry path; it may need the same fix.
>
> Assumed the 30-day refresh window is unchanged; nothing in the issue said otherwise.
>
> ```sh
> mypy auth/ && ruff check auth/               # seconds — run this first
> pytest tests/auth/test_refresh.py -q         # expect 3 passed
> git add auth/refresh.py tests/auth/test_refresh.py
> git commit -m "fix: rotate refresh tokens on use"
> ```

## "Worth exercising" is the highest-value line

You know which branch the test stubs out, which integration you touched but never exercised,
which screen re-renders on the changed state. Two or three specific things beat "please test
it." **For UI changes this is the whole handoff** — hand over a click path precise enough that
they don't have to reconstruct it:

> Worth clicking through: Settings → Billing with an expired card on file. The error banner
> is new, and the retry button should stay disabled until the form re-validates. Also check it
> at narrow width — the banner shares a row with the plan selector.

Be specific about the path: *"log in on two devices, refresh on the older one"*, not
*"test authentication"*.

## Order the commands, cheapest failure first

They paste these in sequence, so a typo should surface before a suite has finished spinning up
fixtures: **typecheck → lint → the one test you wrote → a wider run, only if structural.**
Narrowest scope that covers your change, each time.

Say what they should **see**, not just what to run. `→ clean` and `expect 3 passed` let them
confirm at a glance instead of interpreting output.

## Leave the tree clean

`git status --short` should show only what you meant to change — no debug logging, `.bak`
files, no scratch scripts. Stage nothing, commit nothing, push nothing
([`../boundaries.md`](../boundaries.md)).

## Don't

- Don't paste the diff. They have it.
- Don't narrate the tool calls. They watched.
- **Don't write the summary to a file.** No `CHANGES.md`, no `SUMMARY.md` — this message *is*
  the deliverable ([`code-restraint.md`](code-restraint.md)).
- Don't say "tests added and passing" when you didn't run them.
- Don't end with three offers of further work. One, if there's a real fork.
- Don't commit "to save them a step." That step is theirs.
- Don't run the typechecker "just to be sure" — hand it over as command 1.
