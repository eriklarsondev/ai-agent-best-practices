# Workflow: understanding an unfamiliar codebase

**Open when:** you've just landed in a repo you don't know and need to act in it.
**Skip if:** you only need one known file.

The goal is never "understand the codebase." It's "know enough to make *this* change
correctly." Orient to the task, not the repo.

## The ladder — stop as soon as you can act

1. **Ask the repo directly.** `rg --files -g 'AGENTS.md' -g 'CLAUDE.md' -g 'README*' -g 'CONTRIBUTING*' -g 'docs/adr/*'`
   Read what exists. A good `AGENTS.md` ends onboarding here for a few hundred tokens.
2. **Stack and commands.**
   `rg --files -g 'package.json' -g 'pyproject.toml' -g 'go.mod' -g 'Cargo.toml' -g '*.csproj' -d 2`
   then extract that manifest's task section — per-ecosystem commands in
   [`../reference/stack-commands.md`](../reference/stack-commands.md). You now know how to
   test and build.
3. **Shape, not contents.** `rg --files | head -40`, or `rg --files -d 2`. Top-level
   directories tell you the architecture. Do not `ls -R`.
4. **Entry points.** `rg -n 'def main|func main|^app = |createServer|export default' -m1`
   plus the `main`/`bin`/`scripts` field from step 2.
5. **Find your task's surface.** Grep for the domain noun from the request — the feature name,
   the route, the error string the user pasted. This lands you in the right subtree faster than
   any architectural tour.
6. **Read two neighbours** of the file you'll change. Conventions settled.

Most tasks stop at step 5 or 6. Total: under 10k tokens.

## When it's genuinely broad

If the change really does span subsystems, delegate the survey rather than reading it —
one subagent per subsystem, each returning a fixed-shape summary. Their reads never enter your
window. See [`../practices/delegation.md`](../practices/delegation.md).

## Anchor on runtime behavior, not structure

Cheaper than reading architecture: find the test for the thing you're changing and read it.
Tests state the contract, the fixtures show the data shapes, and the file name tells you what
the module is for.

```sh
rg --files -g '**/*{test,spec}*' | rg -i 'auth'
```

## Don't

- Don't build a mental map of the whole repo before touching anything. You'll spend the
  budget on context you won't use.
- Don't read the dependency list to "understand the stack." Grep for the import you care about.
- Don't open `dist/`, generated clients, or migrations you aren't changing.
- Don't summarize the architecture back to the user unless they asked.
