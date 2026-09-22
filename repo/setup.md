# Repo setup

**Open when:** setting up a repo so agents are cheap to run in, or an agent keeps
rediscovering the same facts.
**Skip if:** you're a guest in someone else's repo and not changing its structure.

This is the other half of the contract. Most agent token waste is a repo problem, not an agent
problem — a repo that can't be searched or tested narrowly forces expensive behavior.

## 1. Ship an `AGENTS.md` at the root

One page, max. Start from [`../templates/AGENTS.md`](../templates/AGENTS.md); what belongs in
it and what doesn't is in [`writing-agents-md.md`](writing-agents-md.md). It's loaded every
session, so it pays for itself the first time it prevents one wrong guess — and it costs on
every turn, so keep it short.

Put in it only what an agent **cannot cheaply infer**: the test-one-file command, the
non-obvious layout rule, the directory that's generated, the env var without which nothing
boots. Leave out anything two neighbouring files already demonstrate.

## 2. Provide narrow, fast commands

The single highest-leverage change. The agent writes tests and hands over the command; the
developer runs it. If the only option is a 12-minute full suite, that handoff stalls every
time — and a check nobody runs is a check you don't have.

Give every repo a named **test-one-file** target and a **narrow check** target, wherever your
ecosystem keeps its tasks — npm `scripts`, a `Makefile`, `justfile`, `Taskfile`, Gradle
task, Maven profile, `mix alias`, or a `scripts/` shell wrapper. A `Makefile` works
everywhere and is the safe default when the ecosystem has no convention:

```make
test-one:   ## make test-one FILE=tests/test_auth.py::test_refresh
	pytest $(FILE) -q
check:
	ruff check src/ && mypy src/
```

Aim for **a sub-10-second check that catches most breakage.** Make failure output short and
top-loaded. Then put both commands in `AGENTS.md` — an agent that has to derive them will
guess wrong, and hand you an invocation that doesn't run.

## 3. Make the tree searchable

- `.gitignore` all build output; ripgrep honors it for free.
- Add a `.ignore` for anything generated but committed (`**/generated/`, `*.pb.go`,
  `__snapshots__/`) so `rg` skips it without you passing globs every time.
- Keep generated code in clearly-named directories, with a header comment saying it's
  generated and what regenerates it.
- Prefer boring, predictable layout over clever layout. A file where its name implies is worth
  more than an elegant abstraction an agent has to reverse-engineer.

## 4. Write down the "why"

Short ADRs in `docs/adr/` are read cheaply and stop agents from re-deriving (or reverting)
decisions. One page each: context, decision, consequence. Template:
[`../templates/adr.md`](../templates/adr.md).

## 5. Keep the loop tight

| Symptom | Fix |
| --- | --- |
| Agent hands back a test command that doesn't run | add `test:one` and document it |
| Agent re-asks about conventions every session | put it in `AGENTS.md` |
| Diffs full of lockfile churn | commit lockfiles, exclude them via pathspec in docs |
| Agent greps `dist/` | `.gitignore` / `.ignore` it |
| Agent can't start the app | document required env vars and the one boot command |
| Agent reverts a deliberate choice | write the ADR |

## Test your own setup

Give a fresh agent a small, real task and watch where it wastes reads. Whatever it had to
discover the expensive way belongs in `AGENTS.md` — that loop is how the file gets good.
