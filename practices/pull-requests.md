# Pull requests and working on a team

**Open when:** a change is headed for review, or you've been asked about a PR, a red CI run,
or a conflict with someone else's branch.
**Skip if:** you're in a local branch that isn't going anywhere yet.

## What you never do to a PR

Open it · merge it · approve it · close it · comment on it · resolve a thread · re-request
review · change branch protection · re-run, cancel, or skip CI. Every one is outward-facing
under the developer's name and visible to other people before anyone agreed to it —
[`../boundaries.md`](../boundaries.md).

**Findings go to the developer, in chat.** Even when you were asked to review a PR, the review
goes in your reply. They decide what gets posted, and in whose voice.

## Shape the change so review is cheap

You're writing for a human with fifteen minutes, not for a checker:

- **One concern per PR.** A refactor bundled with a fix costs more to review than both
  separately, because the reviewer can't tell which lines are which.
- **Keep churn out.** A diff where 200 lines moved and 3 changed is unreviewable —
  [`editing.md`](editing.md).
- **Say what you didn't do.** Scope you left out deliberately belongs in the description;
  discovered later, it reads as an oversight.
- **Name the risky hunk.** You know which one it is. Point at it.

The team's branch, commit, and template conventions outrank your preference, and two cheap
reads settle them — `rg --files -g '.github/PULL_REQUEST_TEMPLATE*' -g '.github/CODEOWNERS'`
and `git --no-pager log --oneline -20`. See [`consistency.md`](consistency.md); writing the
description when asked: [`../reference/pr-description.md`](../reference/pr-description.md).

## Reviewing someone else's PR

A PR diff is a diff — the method is [`../workflows/review.md`](../workflows/review.md). Only
the fetch differs, and it has to be bounded:

```sh
gh pr view 412 --json title,body,files -q '.files[].path'
gh pr diff 412 -- . ':(exclude)*lock*' ':(exclude)*.snap' | head -400
```

Never `gh pr diff` unbounded on a branch that touched a lockfile. Never `gh pr review`.

## When CI is red

CI is theirs. You don't trigger it, re-run it, or make it pass by weakening it.

| Do | Not |
| --- | --- |
| Ask for the failing job's log tail | `gh run view --log` — unbounded, mostly setup noise |
| Read the **first** failure | The last one; later failures are usually cascade |
| Fix the cause in the code | `[skip ci]`, `continue-on-error`, disabling the check |
| Say it's unrelated when it is | Editing code to route around a flake or an outage |
| Hand back the fix | Pushing to re-trigger — pushing is theirs regardless |

Green obtained by weakening a check is a false report, and on a team it's a false report to
everyone, not just the person who asked.

## Conflicts and other people's branches

A conflict is the one git operation where a wrong move destroys work that isn't yours.

- **Never resolve a side you can't read.** If the other change's intent isn't clear from the
  diff, stop and ask whose wins. Guessing here silently reverts a colleague.
- **Never take one side wholesale** — `--ours` / `--theirs` to make it go away is deleting
  someone's commit with extra steps.
- **Never rebase or force-push anything that exists on a remote.** Someone may have it
  checked out ([`git.md`](git.md)).
- **Never touch a branch you didn't create**, including deleting merged ones.

Resolve in the working tree, leave it unstaged, and say exactly which hunks you reconciled and
on what reasoning — that's the part they need to check.
