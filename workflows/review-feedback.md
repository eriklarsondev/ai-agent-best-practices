# Workflow: responding to review feedback

**Open when:** review comments came back on a change.
**Skip if:** you're the one reviewing — that's [`review.md`](review.md).

## 1. Read everything before touching anything

Fix the first comment and re-read, and you'll redo work: comment 7 often changes what comment
2 should look like, and two comments frequently point at the same underlying thing. Read the
whole set, then act once.

## 2. Sort them into three piles

| Pile | Response |
| --- | --- |
| **Direct fix** — "this should be `>=`" | Make the change |
| **Question** — "why does this clear the cache?" | Answer in words. Not every comment wants code |
| **Disagreement** — you think the reviewer is wrong | One sentence of why, then implement it anyway |

The middle pile is the one agents get wrong most: a reviewer asking *why* usually wants to
understand the change, not alter it. Rewriting code in response to a question destroys the
thing they were trying to understand.

## 3. Don't relitigate

If the reviewer made a call, implement it. If you believe it's mistaken, say so **once**, in
a sentence, and do it their way unless they come back:

> Switched to the mutex as asked. Worth noting the contention will show up under the
> batch job — happy to revisit if it does.

That's the whole disagreement. A second round of argument costs more than the change ever
will, and it's their codebase.

## 4. Address what was raised — nothing else

A comment on line 40 is not a licence to refactor the file. Feedback is the narrowest possible
scope: it's the one moment where the reviewer has stated exactly what they want, so there is
no ambiguity to resolve generously. Anything you noticed while in there goes in your summary
as a sentence, not into the diff — see [`../practices/code-restraint.md`](../practices/code-restraint.md).

## 5. When a comment invalidates an assumption

Sometimes a reviewer reveals you were wrong about something structural — *"we never hit this
path from the worker"*. Say what else that invalidates, rather than silently fixing the one
line they pointed at:

> That changes two other things I did on the same assumption — the retry guard in
> `queue.py:88` and the test I wrote for it. Fixed both.

## 6. Re-grep, then map comments to changes

Feedback edits break things as readily as original ones — re-run the same greps and re-read
the hunks you touched. Then give them one summary keyed to their comments, so they can verify
without re-reading the diff:

> - `auth.py:40` `>=` — fixed
> - `auth.py:55` why clear the cache — answered below, no change
> - `queue.py:88` mutex — done, plus the two dependent spots above
>
> Worth re-running `mypy auth/ && ruff check auth/` — three more lines changed since your
> last look, and I haven't run anything.
>
> Why the cache clear: the session object caches the old token, so without it a refresh
> returns the pre-rotation value on the next read.

## Don't

- Don't resolve threads or mark comments done — that's the reviewer's signal to give.
- Don't push, amend, or force-push — [`../boundaries.md`](../boundaries.md).
- Don't apologize per comment. Fix it and move on.
- Don't quietly skip a comment you disagree with. Silence reads as agreement.
