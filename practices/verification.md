# Verification

**Open when:** after a change — **what** to check before you report.
**Skip if:** nothing executable changed.

First in the end-of-task chain: **verification** → [`handoff.md`](handoff.md) (what to say)
→ [`communication.md`](communication.md) (how to write it).

## Where your job ends

Prove the change is **statically sound**, cheaply. Then hand it to the developer to run.

| You do | The developer does |
| --- | --- |
| Type check, compile, lint | Runs the test suite |
| **Write** the tests | **Runs** the tests |
| Grep every call site you changed | Runs the app |
| Read the diff once | Decides it's right |

**Don't execute tests. Don't run the app.** No `pytest`, no `go test`, no `npm test`, no
dev servers, no browser automation, no E2E. No Docker — don't build, start, or restart
containers. And never start the app on a spare port to dodge a conflict: a busy port means
it's already running, and a second instance just creates a second source of truth.

Writing a test is your job; confirming it passes is theirs.

Three reasons, in order of weight:

1. **The developer re-verifies anyway.** They're the one who knows what correct looks like.
   A green run from you doesn't remove a single step from their side — you paid for nothing.
2. **A passing test you wrote and ran proves less than it appears.** If the same pass wrote
   the code and the assertion and then graded them against each other, green mostly confirms
   internal consistency. An independent runner is what makes it evidence.
3. **Execution is the expensive, flaky part.** Suites need env, fixtures, services, and
   ports you're guessing at; browser loops cost tens of thousands of tokens per attempt.

**Exception:** the developer explicitly asks you to run something. Then run it — bounded,
once, output piped to `tail`.

## What you can do instead

Static checks are cheap, deterministic, and often *more* complete than a test run:

| Question | Check |
| --- | --- |
| Does it compile / typecheck? | Narrowest project scope, `2>&1 \| head -30` |
| Does it lint? | The files you touched only |
| Did I miss a call site? | `rg -n 'funcName\('` — finds every one, including those no test covers |
| Did the rename land everywhere? | `rg -n 'oldName'` returning nothing **is** the proof |
| Did I break a config contract? | `rg -n 'KEY_NAME'` across code, compose files, CI, `.env.example` |
| Did I change a DB field? | Grep the migrations and serializers |
| Is the new test actually wired in? | Grep the test path matches the runner's discovery pattern |

Commands per stack: [`../reference/stack-commands.md`](../reference/stack-commands.md).

## Writing the test is still your job

Write it, and write it to fail for the right reason. You just don't get to watch it run.
That raises the bar on the test itself:

- **Assert on behavior, not on implementation** you just wrote — an assertion mirroring your
  own code passes without proving anything.
- **Name the case in the test name**, so a failure tells the developer what broke without
  reading the body.
- **Cover the path you couldn't check statically** — the error branch, the boundary, the
  empty case.
- **Never** mark it skipped, `xfail`, or `.only` to sidestep uncertainty. If you're unsure
  it's right, say so in the handoff.

## Report honestly

- Ran a static check, it passed → say which one, plainly.
- Ran it, it failed → show the relevant slice.
- Wrote tests → say that you wrote them **and did not run them**. Never phrase unrun tests
  in a way that implies they passed.
- Skipped a check → name it and why.

"It compiles" is never a stand-in for "it works," and "I added tests" is never a stand-in
for "the tests pass."

## Then hand off

Give them the exact command for the tests you wrote, plus what's worth exercising by hand.
See [`handoff.md`](handoff.md).
