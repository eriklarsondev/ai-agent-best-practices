# Cost anchors

**Open when:** you need to estimate whether an action is affordable, or to justify delegating.
**Skip if:** the short table in [`../AGENTS.md`](../AGENTS.md) already settles it.

Order of magnitude only, measured loosely on typical TypeScript/Python repos.
Tokens ≈ bytes / 4 for code and prose.

## Reading

| Action | Rough tokens |
| --- | --- |
| `rg -l pattern` (20 hits) | 100 |
| `rg -n pattern` (50 hits with paths) | 1k |
| `rg -n` symbol outline of a large file | 200 |
| Read a 150-line file | 2k |
| Read a 300-line file | 4k |
| Read a 1000-line file | 13k |
| Read a 2000-line file | 25k |
| Read a lockfile (any ecosystem) | 200k – 2M |
| Read a 5MB JSON/CSV fixture | ~1.2M |
| `ls -R` at the root of a JS repo | catastrophic |

## Version control

| Action | Rough tokens |
| --- | --- |
| `git status --short` | 100 |
| `git --no-pager log --oneline -10` | 200 |
| `git log` (paged, full bodies) | 20k+ |
| `git --no-pager diff --stat` | 300 |
| `git diff` of a 200-line change | 3k |
| `git diff` including a lockfile | 50k – 500k |

## Running things

Only the static rows are yours — you don't run tests or the app
([`../practices/verification.md`](../practices/verification.md)). The test rows are here so
you can tell the developer which subset is worth their time.

| Action | Rough tokens |
| --- | --- |
| Exit code only (`>/dev/null; echo $?`) | ~5 |
| One test file's output | 300 |
| Package-scoped test run | 2k |
| Full suite output | 3k – 30k |
| `tsc --noEmit` on a clean repo | 50 |
| `tsc --noEmit` with one error, unbounded | 5k – 50k (cascades) |
| `npm install` unbounded | 1k – 3k |
| Docker build unbounded | 10k – 100k |

## Delegation

| Action | Rough tokens (yours) |
| --- | --- |
| Subagent prompt you write | 200 |
| Subagent report back | 500 – 3k |
| Everything the subagent read | **0** |
| Same search done inline across 30 files | 40k – 120k |

Break-even: delegate when the reads you'd otherwise do exceed ~10k tokens. See
[`../practices/delegation.md`](../practices/delegation.md).

## Conversation

| Action | Rough tokens |
| --- | --- |
| A clarifying round trip | a full turn of re-sent context |
| Restating the request back | 200 |
| Tool-by-tool narration of a 10-call turn | 2k |
| Pasting a diff the user can already see | 1k – 10k |
| `path/file.ts:42` citation | 8 |

## Using these

Before an action, ask: *what will this cost, and what will it decide?* If the cost is more
than a few hundred tokens and you can't name the decision, there's a cheaper move — check
[`antipatterns.md`](antipatterns.md).
