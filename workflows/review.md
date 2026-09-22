# Workflow: reviewing a diff

**Open when:** reviewing changes — yours before reporting, or someone else's.
**Skip if:** the diff is under ~20 lines and you've already read it.

## 1. Shape before contents

```sh
git --no-pager diff --stat main...HEAD
git --no-pager diff --name-only main...HEAD
```

The stat tells you where to spend. A 2000-line change to a generated file needs no review; a
40-line change to auth needs all of it.

## 2. Exclude the noise

```sh
git --no-pager diff main...HEAD -- . ':(exclude)*lock*' ':(exclude)*.snap' ':(exclude)dist/**'
```

Lockfiles, snapshots, and generated output are routinely 90% of a diff's tokens and 0% of its
risk.

## 3. Read the diff, not the files

The diff is the unit of review. Open the surrounding file only when a hunk is unreadable
without it — usually because you can't tell what a changed condition guards.

```sh
git --no-pager diff main...HEAD -- src/auth/session.ts
```

## 4. What to actually look for

Ranked by how often it matters, and by what a type checker won't catch for you:

| Check | Why it's first |
| --- | --- |
| Does it do what was asked? | The most common real defect is scope, not syntax |
| Error and empty paths | The happy path is the one that got tested |
| Boundary conditions | Off-by-one, empty collection, null, zero, timezone |
| Concurrency and ordering | Tests rarely cover it; failures are expensive |
| Call sites of changed signatures | `rg -n 'name\('` — the compiler misses dynamic ones |
| Security-shaped changes | Authz per route, injection, trust boundaries, secrets in logs — [`../practices/secure-coding.md`](../practices/secure-coding.md) |
| Migrations and contract changes | One-step destructive migrations, locks, removed response fields — [`../practices/migrations.md`](../practices/migrations.md) |
| Tests that assert the new behavior | Not just that they exist — that they'd fail without the change |
| Anything weakened to pass | `@ts-ignore`, skipped tests, loosened assertions |

Skip: formatting, style the linter owns, naming preferences, and anything the repo's own
tooling already enforces. Reviewing what a tool checks is pure token cost.

## 5. Verify the risky claim, don't trust the summary

If the change hinges on one assumption — "this is the only caller," "this field is always
set" — spend the one grep to check it. A 50-token verification against a claim the whole
change rests on is the best trade in review.

## 6. Report

Ranked most severe first. Each finding: the file:line, what breaks, and the concrete input
that breaks it. A finding without a failure scenario is usually a preference.

Say plainly when you found nothing. Manufactured findings waste more time than they save.
