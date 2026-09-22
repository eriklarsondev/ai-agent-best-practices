# When you're stuck

**Open when:** the same thing has failed twice.
**Skip if:** you're making progress — each attempt is teaching you something new.

## Two attempts, then stop

The second failure is the signal, not the third. A third pass at the same approach is
thrash: it burns context, buries the working state under half-edits, and produces a longer
explanation of a worse diff.

**Same attempt** = same hypothesis, different spelling. Renaming a variable, reordering
arguments, adding a cast, trying the other quote style.
**New attempt** = a different theory of *why* it broke.

If you can't state why attempt 1 failed, attempt 2 is a guess — and guessing twice is where
the thrash starts.

## Before attempt two, say the hypothesis

Out loud, in one line: *"It failed because the config is loaded before the env var is set."*
Then the next attempt tests that specific thing. If the hypothesis was wrong, you've learned
something and earned a third attempt on a **new** hypothesis. If you had no hypothesis, you
haven't.

## The ladder, in order

1. **Re-read the error, not the code.** The first line of a stack trace, not the twentieth.
   Agents skip this constantly and pattern-match to a familiar-looking bug instead.
2. **Check the assumption with a grep.** "This is the only caller" · "this file is the one
   that runs" · "that flag is set". One `rg` settles it.
3. **Question the premise.** Is the file even loaded? Is the test discovering? Is the build
   stale? Is this the environment you think it is?
4. **Stop and hand back.**

## What "stop" looks like

Not: silently narrowing scope, shipping a partial and calling it done, deleting the failing
assertion, wrapping it in a try/except, or adding defensive code to suppress a symptom. Those
convert a visible problem into an invisible one.

Instead, report:

> Stuck on the refresh test. Tried (1) moving the revocation check before expiry — still
> returns 200; (2) forcing a session flush first — same. I think the fixture is issuing a
> token that's already in the revoked set, so the assertion passes for the wrong reason, but
> I can't confirm without running it. Could you run `pytest tests/auth -q -k replay` and
> paste the output?

That's four lines and it moves the work forward. Twenty more minutes of attempts doesn't.

## "Stuck" often just means "can't observe"

Given that you don't run things ([`running-things.md`](running-things.md)), a lot of dead
ends are really missing information, not missing ideas. That's not failure — it's the normal
shape of the work. Hand over the **specific question** you need answered:

> Does `config.load()` run before or after `dotenv` in your setup? That determines which of
> two fixes is right, and I can't tell from the code alone.

A precise question gets a precise answer in one turn. Flailing gets neither.

## Signals you're already thrashing

- You've edited the same lines three times.
- You're re-reading files you read twenty turns ago.
- The diff is growing while the problem stays the same.
- You're adding error handling for a case you don't understand.
- Your explanation is getting longer as your confidence drops.

## Leave it clean

If failed attempts left debug logging, commented-out code, or `.bak` files, remove them
before reporting. `git status --short` should show only what you meant to change — handing
back a mess on top of "I'm stuck" costs them twice.
