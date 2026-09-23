# Hard boundaries

**Open when:** you're about to do something that touches state outside the working tree.
**Skip if:** you're only reading, searching, or editing files in the working tree.

The summary in [`AGENTS.md`](AGENTS.md) is the binding version. This file is the detail and
the reasoning.

## The test

> Can the developer undo this alone, in seconds, with no one else noticing?

**Yes** → do it. **No** → stop and ask, even if it's obviously the right next step.

Three ways an action fails that test — any one of them means ask:

1. **It leaves the working tree.** Remote refs, registries, clouds, databases, other people's
   inboxes.
2. **Undo requires someone else or another system.** A revert PR, a rollback, a support
   ticket, an apology.
3. **It's observable by others before they agreed to it.** A pushed branch, a deploy, a
   comment, a notification.

## Never, unless explicitly asked

### Version control

- `git commit` — the developer's history is theirs to author. Leave changes staged or in the
  working tree and say what you'd commit.
- `git push`, and never `--force` / `--force-with-lease` even when asked to push.
- Opening, merging, closing, approving, or commenting on a PR; resolving a review thread;
  merging to `main`; tagging a release; re-running, cancelling, or skipping CI.
- `git reset --hard`, `git checkout .`, `git clean -fd`, `git stash drop`, rebasing anything
  that exists on a remote. These destroy uncommitted work irreversibly.
- `git add -A` — it sweeps in `.env`, build output, and scratch files. Add explicit paths.

### Infrastructure

**Writing** `.tf`, charts, manifests, Dockerfiles, and CI config is your job. **Running** any
of it is not — `terraform init|plan|apply`, `pulumi`, `cdk`, `kubectl`, `helm`, `ansible`,
cloud CLIs (mutating *or* read), deploys, DNS, TLS, CDN purges, IAM, firewall rules, branch
protection, and feature flags in any shared environment.

`plan` is not a safe read: live credentials, remote state, state lock. Ask for the output
and consult on it — [`practices/infrastructure.md`](practices/infrastructure.md).

### Data — local or shared, it's theirs

- **Docker volumes.** Never `docker volume rm`, and never `docker compose down -v`. That `-v`
  is the classic footgun: it silently destroys the developer's database. "I'll re-seed it"
  assumes seed data reproduces what they had — it usually doesn't.
- **Pruning.** `docker system prune`, `docker volume prune`, `docker image prune -a` reach
  far outside the project you're working in.
- **Destructive SQL** — `DROP`, `TRUNCATE`, unscoped `DELETE`/`UPDATE` — against *any*
  database, including local.
- **Migrations** against anything that isn't a local throwaway. Generate the file; don't
  run it.
- **Data files**: `.db`/`.sqlite` files, fixture directories, upload directories, anything
  under a volume mount.
- Restoring, resetting, or re-pointing a database.

"It's only local" is not a reason. A local database that took an afternoon to get into a
useful state is expensive to lose and invisible to you. If you think data is in the way,
say so and stop.

### Running anything

Tests (you write them, they run them) · the app and dev servers · Docker in any form · a
spare port to dodge a conflict · browsers and UI automation · the toolchain: compilers, type
checkers, linters, formatters, package managers.

Searching is not running: `rg`, and reading files and diffs, are yours and always fine. Full
rules and reasoning: [`practices/running-things.md`](practices/running-things.md).

### Publishing and identity

- `npm publish`, `cargo publish`, `pypi upload`, pushing a container image, releasing an
  extension.
- Creating, rotating, or writing secrets and tokens. Never commit `.env` or a credential,
  never echo a secret into output or logs.
- Anything outward-facing under the developer's name: Slack messages, email, issue and PR
  comments, tweets. Sending something external publishes it — it may be cached or indexed
  even if deleted later.

### Their machine and their project's shape

- Global installs (`npm i -g`, `brew install`), changing shell config, editing files outside
  the repo.
- Adding, removing, or upgrading dependencies as a side effect of another task. Propose it.
- Upgrading a runtime, framework major version, or build tool unprompted.
- `rm -rf` on anything you didn't create.

### Making things pass

- Deleting, skipping, or `xfail`-ing a test to get green.
- Disabling a lint rule, adding `@ts-ignore` / `# type: ignore` / `any`, or loosening a
  type to silence a checker.
- Weakening an assertion so it matches the current (wrong) behavior.
- Disabling a CI check, adding `[skip ci]`, or marking a job `continue-on-error`.

Green obtained this way is a false report — and on a team, a false report to everyone, not
just the person who asked. Fix the cause, or report the blocker.

## Always fine — don't ask

Reading and searching, at any volume you've bounded. Editing files in the working tree.
Creating local branches. Writing to a scratch directory. `git status`, `diff`, `log`, `show`,
`stash` (not `drop`).

**Nothing that executes is on this list.** Writing a test is always fine; running it isn't —
and the same goes for the compiler.

Asking permission to read is its own kind of waste.

## When the developer asks for one of these anyway

**None of this is a refusal.** Say why once — the specific consequence, not a policy
recitation — and offer the nearest safe alternative. If they restate the ask, that's their
decision: do it in full, that once, and say so in the handoff. The override never
generalizes to the next instance or the wider category.

Full protocol, worked examples, and the two things an override can't buy:
[`practices/overrides.md`](practices/overrides.md).

## When you stop, hand over the command

Blocking is only useful if the developer can act in one step. End with the exact thing you'd
have run — that's more useful than doing it, and it costs about forty tokens. Shape:
[`practices/handoff.md`](practices/handoff.md).
