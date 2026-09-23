# AGENTS.md

<!--
  Loaded on every turn of every session. Keep it to one page.
  Include only what an agent would otherwise get wrong, or get right expensively.
  Delete every section you don't fill in — an empty heading is pure cost.
  Guidance: repo/writing-agents-md.md · Commands per stack: reference/stack-commands.md
-->

## Stack

<!-- One line. e.g.
     Python 3.12 · FastAPI · Postgres (SQLAlchemy) · uv
     Go 1.23 · chi · sqlc · Postgres
     Java 21 · Spring Boot · Gradle · Postgres (Flyway)
-->

## Commands

| Task | Command |
| --- | --- |
| Install | |
| Run locally | |
| **Test one file** | |
| Test all | |
| Typecheck / compile | |
| Lint / format | |
| Build | |

<!-- "Test one file" is the highest-value row — it's the command the agent hands back for
     you to run. Without it you get a guess. -->

## Layout

<!-- 5-10 lines max. Only what a two-level file listing wouldn't make obvious.
api/handlers/    HTTP layer — one file per resource, no business logic
core/            domain logic, no I/O
internal/gen/    DO NOT EDIT — regenerate with `make generate`
-->

## Conventions

<!-- Only what two neighbouring files don't already demonstrate.
- Errors: raise AppError subclasses; never return None to signal failure
- All timestamps stored and compared in UTC
- Repository classes own transactions; services never open one
-->

## Do not edit

<!-- Generated, vendored, or externally-contracted files.
internal/gen/**    regenerate with `make generate`
migrations/**      append only, never modify a shipped migration
-->

## Gotchas

<!-- The things that waste an hour.
- Needs DATABASE_URL, and `docker compose up -d db` must already be running
- Full suite is ~9 min — hand back the single-file command instead
- IntegrationTest#checkout is flaky; rerun before investigating
-->

## Boundaries

Ask before: committing, pushing, opening PRs, deploying, infra or IaC changes, migrations
against anything shared, publishing, touching secrets, or adding dependencies.

<!-- Override here only if you want a standing exception, e.g.
- OK to commit without asking on `feat/*` branches. Still never push.
-->
