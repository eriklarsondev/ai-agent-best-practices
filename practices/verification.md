# Verification without execution

**Open when:** after a change — how to check it when you can't run anything.
**Skip if:** nothing executable changed.

First in the end-of-task chain: **verification** → [`handoff.md`](handoff.md) (what to say)
→ [`communication.md`](communication.md) (how to write it).

## Checking is reading, grepping, and honesty

| You do | The developer does |
| --- | --- |
| Re-read your own diff | Compiles, typechecks, lints |
| Grep every call site you touched | Runs the test suite |
| **Write** the tests | **Runs** the tests |
| Name what you couldn't check | Decides it's right |

**Don't run the toolchain to grade yourself** — no `tsc`, `mypy`, `eslint`, `go build`, no
test runner, dev server, Docker, or browser. Rules and reasoning:
[`running-things.md`](running-things.md).

Three reasons, in order of weight:

1. **The developer re-verifies anyway.** They know what correct looks like. Nothing you run
   removes a step from their side, so you paid for nothing.
2. **Self-graded green proves less than it appears.** If one pass wrote the code, wrote the
   assertion, and graded them against each other, passing mostly confirms internal
   consistency. An independent runner is what makes it evidence.
3. **Execution costs most exactly when your change is worst.** A single type error cascades
   into thousands of lines you can't un-read; a browser loop is tens of thousands of tokens
   per attempt. The worse the state, the bigger the bill.

**Exception:** the developer explicitly asks you to run something. Then run it — bounded,
once, output piped to `tail`.

## The three moves that replace it

**1. Re-read the diff as if it were someone else's.** You wrote it from intent; read it from
outside. Most of what a type checker would have caught — the wrong field name, the argument
in the wrong position, the import that doesn't exist — is visible on the second read and
invisible on the first.

**2. Grep the blast radius.** Cheap, deterministic, and it catches things a test run misses:

| Question | Check |
| --- | --- |
| Did I miss a call site? | `rg -n 'funcName\('` — every one, including those no test covers |
| Did the rename land everywhere? | `rg -n 'oldName'` returning nothing **is** the proof |
| Does what I imported exist? | `rg -n 'export .*thingIImported'` in the source module |
| Did I break a config contract? | `rg -n 'KEY_NAME'` across code, compose files, CI, `.env.example` |
| Did I change a DB field? | Grep the migrations and the serializers |
| Is the new test wired in? | Grep that its path matches the runner's discovery pattern |

**3. Name what you couldn't check.** Ranked, most-likely-wrong first. This is worth more than
a green check you produced yourself, because it's the one thing the developer can't derive.

Commands to hand over, per stack:
[`../reference/stack-commands.md`](../reference/stack-commands.md).

## Writing the test is still your job

Write it, and write it to fail for the right reason. Not watching it run raises the bar on the
test itself:

- **Assert on behavior, not on implementation** you just wrote — an assertion mirroring your
  own code passes without proving anything.
- **Name the case in the test name**, so a failure tells the developer what broke without
  them reading the body.
- **Cover what reading couldn't settle** — the error branch, the boundary, the empty case.
- **Never** mark it skipped, `xfail`, or `.only` to sidestep uncertainty. Say so instead.

## Report honestly

- Grepped the call sites → say which pattern, and how many hits it returned.
- Wrote tests → say you wrote them **and did not run them**. Never phrase unrun tests in a
  way that implies they passed.
- Couldn't check something → name it, don't omit it.

You have no green to report. "It looks right" is not "it works," and "I added tests" is not
"the tests pass" — so report what you actually did, which is reading and grepping.

## Then hand off

Give them the commands — checks first, then tests — plus what's worth exercising by hand.
See [`handoff.md`](handoff.md).
