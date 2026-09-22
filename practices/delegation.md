# Delegation and parallelism

**Open when:** deciding whether to spawn subagents or parallelize.
**Skip if:** the task touches files you've already located.

## The break-even

A subagent costs you: your prompt (~200) + its final report (~500–3k). Everything it *reads*
costs you nothing — that's the whole point. It runs its own window and hands back a conclusion.

So delegate when the work it replaces would cost **more than ~10k tokens of your own reads**.

| Task | Call |
| --- | --- |
| "Where is `parseConfig` defined?" | Do it yourself — one grep |
| "Read `src/auth/session.ts` lines 40–90" | Do it yourself |
| "Which of our 40 route handlers skip auth?" | Delegate |
| "Map how errors propagate across these 6 subsystems" | Delegate |
| "Find every place we assume UTC" | Delegate |
| "Summarize this 4000-line file" | Delegate — the reading never enters your window |

Rule of thumb: **delegate breadth, do depth yourself.**

## Write the deliverable into the prompt

The single biggest win. A vague mission returns prose you then have to read and re-parse.

> ✗ "Look into how auth works."
>
> ✓ "Find every Express route that doesn't pass through `requireAuth`. Return one line per
> hit as `path/to/file.ts:LINE  METHOD /route`. No prose, no explanation. If there are none,
> return `NONE`."

Specify: the exact question, the output format, the cap ("at most 20"), and what to do when
the answer is empty. A structured schema beats a format request when available.

## Rules

- **Never delegate and also do it yourself.** Pick one. Duplicating the search doubles cost
  and produces two answers to reconcile.
- **Launch independent agents in one message** so they run concurrently. Sequential spawns
  serialize wall-clock for no reason.
- **Subagents don't have your conversation.** Anything they need — the user's constraint, the
  decision from ten turns ago, the file you already found — must be in the prompt.
- **Don't delegate the edit** unless the agent has everything needed to make it correctly.
  Delegation is strongest for read-heavy fan-out, weakest for judgment that depends on context
  you hold.
- **Their report is a claim, not a fact.** If a conclusion is load-bearing, spot-check the one
  `file:line` it hinges on — a 50-token read against a 3k-token report.

## Parallelism in your own turn

Independent tool calls go in one message. Three greps, or a grep plus a `git log` plus a
`jq`, are one round trip — not three. Only serialize when a call's input depends on a
previous call's output.
