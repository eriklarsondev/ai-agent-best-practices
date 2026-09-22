# Running things

**Open when:** you're about to execute anything — a test, the app, Docker, a browser.
**Skip if:** it's a static check (compile, typecheck, lint, grep). Those are always yours.

## The line

| Yours | The developer's |
| --- | --- |
| Compile, typecheck, lint | Tests, at every level |
| Grep, search, read | The app, dev servers, Docker |
| **Writing** tests | **Running** tests |
| Reading the diff | Clicking through the UI |

Static analysis is deterministic, bounded, and needs no environment. Execution needs env
vars, fixtures, services, seed data, and ports — all of which you're guessing at, and any of
which can fail for reasons that have nothing to do with your change.

## Never

**Tests.** No `pytest`, `go test`, `npm test`, `mvn test`, `cargo test` — unit, integration,
or E2E. Write them, name the command, hand it over.

**The app.** No dev servers, no long-lived processes, no `curl` against something you
started.

**Docker.** No `compose up/down/restart`, no `build`, no `run`, no container restarts. The
developer owns their stack — they know what's running and what state it holds. A container
you restart may have had their seed data in it.

**A spare port.** If the port is busy, the app is *already running* and that's their server.
Starting a second instance on `:3001` gives you a process that shares none of their state,
tells you nothing the first wouldn't, and leaves a stray listener behind. Never route around
a port conflict — report it.

**A browser.** No Playwright, Puppeteer, Selenium, Cypress, screenshot loops, or visual
diffing. This is the single most expensive thing an agent can do: tens of thousands of tokens
per attempt, attempts come in threes, and most of the spend goes into fighting the harness
rather than finding bugs.

**Infrastructure commands — including the read-only-looking ones.** `terraform init|plan|
apply`, `kubectl`, `helm`, `aws`/`gcloud`/`az`. Writing the config is your job; running it
isn't. `plan` in particular looks safe and isn't: it needs live credentials, reads remote
state, and can take a state lock. Ask for the output and interpret it —
[`../boundaries.md`](../boundaries.md).

## Why, beyond cost

- **They re-verify anyway.** Nothing you run removes a step from their side.
- **Self-graded green is weak evidence.** If one pass wrote the code, wrote the assertion,
  and ran them against each other, passing mostly proves internal consistency. An independent
  runner is what makes it evidence.
- **They're faster at judging UI.** A developer spots a wrong interaction in five seconds
  where a browser loop burns 40k tokens confirming a DOM node exists.

## What to do instead

Hand over a click path or a command precise enough that they don't have to reconstruct it —
see [`handoff.md`](handoff.md). Name the risk you couldn't check:

> Worth clicking through: Settings → Billing with an expired card. The error banner is new,
> and the retry button should stay disabled until the form re-validates.

## The one exception

The developer explicitly asks you to run something. Then run it — bounded, once, output piped
to `tail -30`. An instruction to run the tests is not standing permission to start the app,
and vice versa.
