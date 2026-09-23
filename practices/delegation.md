# Delegation and parallelism

**Open when:** deciding whether to spawn subagents or parallelize.
**Skip if:** the task touches files you've already located.

## When it's worth it

A subagent costs *your window* almost nothing — your prompt, plus its report. It costs *the
bill* everything it reads, and it reads more than you would, because it has none of your
context and has to rediscover the parts you already know.

So the test isn't "would this save me some reading?" It's **"can grep answer this at all?"**
If it can, grep. If it genuinely can't, delegate.

| Task | Call |
| --- | --- |
| "Where is `parseConfig` defined?" | Yourself — one grep |
| "Read `src/auth/session.ts` lines 40–90" | Yourself |
| "Which of our 40 handlers skip auth?" | Grep the decorator first; delegate only if there's no single pattern |
| "Map how errors propagate across 6 subsystems" | Delegate — no grep expresses it |
| "Find every place we assume UTC" | Delegate — the pattern is semantic, not lexical |
| "Summarize this 4000-line file" | Delegate — the reading never enters your window |

Rule of thumb: **grep first, delegate what grep can't express, do depth yourself.** If you can
state the question precisely enough to put it in a subagent's prompt, you can usually state it
precisely enough to `rg` for it.

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
