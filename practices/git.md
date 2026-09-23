# Git

**Open when:** inspecting history, or the developer has asked you to commit.
**Skip if:** you're not touching version control.

## Never let git paginate into your context

Pass `--no-pager`, or export `GIT_PAGER=cat` once. A pager-less `git log` in a mature repo is
tens of thousands of tokens.

## Inspect cheaply

Always `--stat` before contents; always scope with `-- path`. Full command list in
[`../reference/cheatsheet.md`](../reference/cheatsheet.md). Two tricks are worth memorizing.

**Exclude the noise from every diff:**

```sh
git --no-pager diff -- . ':(exclude)*lock*' ':(exclude)*.snap' ':(exclude)dist/**'
```

One lockfile in a diff is routinely 100k+ tokens carrying zero information.

**Blame one line without walking history:**

```sh
git --no-pager log -1 --format='%h %an %ad %s' -L 42,48:src/foo.ts
```

Answers "why is this line here" for ~100 tokens.

## Writing to history is the developer's job

**Don't commit. Don't push. Don't open, merge, or approve a PR.** Not a courtesy — the
developer tests, stages, commits, and pushes, and that sequence is theirs to author. They're
also the one who knows whether the change is actually right.

Leave the change in the working tree, unstaged. Hand over the exact commands instead — see
[`handoff.md`](handoff.md) and [`../boundaries.md`](../boundaries.md).

## If you are explicitly asked to commit

- Branch first if you're on the default branch.
- `git add` **specific paths**. Never `git add -A`: it sweeps in `.env`, build output, and
  scratch files.
- Check before you commit: `git --no-pager diff --cached --stat`.
- One logical change per commit. The message says *why*; the diff already says what.
- Still don't push. Approval to commit is not approval to push.

## Never without confirming

`git reset --hard` · `git checkout .` · `git clean -fd` · `git stash drop` · rebasing
anything that exists on a remote · any force-push.

These destroy uncommitted work irreversibly, and the work they destroy is usually the
developer's, not yours.

## On a team

Never touch a branch you didn't create, never resolve a merge conflict by taking one side
wholesale, and never rebase or force-push a branch someone else may have checked out. Full
rules, plus PRs and CI: [`pull-requests.md`](pull-requests.md).

## Pull requests

**Never open one.** Not as a convenience, not when the branch is obviously ready. Opening,
merging, and approving are the developer's.

When they ask you for a **description**, write it to the house format — markdown, no hard
line breaks, headings no larger than `####`, a short comprehensive summary followed by
highlights grouped server-side → client-side → infrastructure. Spec and worked example:
[`../reference/pr-description.md`](../reference/pr-description.md).
