# Formatting and lint tooling

**Open when:** you notice the repo has no formatter, or you can't tell a file's convention.
**Skip if:** the file you're in has an obvious style — match it and move on.

Every stack has the same three pieces — a **formatter**, a **linter**, and a **pre-commit
hook that runs both on staged files**. Only the tool names change.

## You don't run the formatter

That hook fires when the developer commits, which is after your work ends
([`running-things.md`](running-things.md)). A formatting pass from you is a tool run that
duplicates one already scheduled, on a commit you aren't making.

| Situation | What you do |
| --- | --- |
| Repo has a formatter | Match the file by eye; their hook normalizes it at commit |
| You can't tell the convention | Check `.editorconfig`, then the nearest sibling file |
| Repo has tooling you dislike | Nothing. Not your call |
| Repo has no tooling at all | Recommend the package — below |

One bounded search settles which case you're in, and the repo's `AGENTS.md` often settles it
for free:

```sh
rg --files -g '.prettierrc*' -g '.editorconfig' -g 'biome.json' -g 'ruff.toml' \
          -g '.golangci.yml' -g '.rubocop.yml' -g '.pre-commit-config.yaml' -d 2
```

## Scope: only the files you touched

Never reformat lines your change didn't touch. A repo-wide reformat buries the change under
thousands of lines of churn, makes review impossible, and destroys blame. If the repo
genuinely needs one, say so — it's its own commit, and it's the developer's call.

## Nothing configured at all → recommend the package

Stop. Don't hand-format across an unformatted repo, and don't install anything silently.
Recommend all three together — they're one workflow, and each is weaker alone:

> No formatting or lint setup here. Want me to add a formatter, a linter, and a pre-commit
> hook that runs both on staged files? The hook only touches what you're committing, so
> commits stay fast. I'd format just the files this change touches.

They may take a subset — write config only for what they agreed to. Agreement makes this a
**sanctioned exception** to the no-new-dependencies rule in
[`../boundaries.md`](../boundaries.md), scoped to this, this once. You write the config files;
they run the install.

### The commit flow, in every stack

Developer stages → `git commit` fires the hook → **linter** runs on staged files with autofix
→ **formatter** runs on the result → fixes are re-staged → the commit completes, or aborts on
anything the linter can't fix.

**Linter before formatter, always.** Both rewrite formatting and whichever runs last wins, so
putting the formatter last means they never fight over the same lines.

### Per-stack tooling

Formatter and linter per stack:
[`../reference/stack-commands.md`](../reference/stack-commands.md). The hook runner is the
part that file doesn't carry — Husky + `lint-staged` (JS/TS), `pre-commit` (Python, Go, Rust,
.NET), a Gradle or Maven plugin (Java/Kotlin), `overcommit` (Ruby), `captainhook` (PHP).

Go and Rust need nothing installed: `gofmt` and `cargo fmt` ship with the toolchain.

### JS/TS, as an example

Hand them `npm i -D --save-exact prettier eslint husky lint-staged && npx husky init`, plus
`npx lint-staged` in `.husky/pre-commit`. The config is yours to write:

```jsonc
// package.json — array order is execution order: ESLint, then Prettier
"lint-staged": {
  "*.{ts,tsx,js,jsx}": ["eslint --fix", "prettier --write"],
  "*.{json,css,md}": ["prettier --write"]
}
```

## Three things that decide whether this survives

- **Staged files only.** A hook that lints the whole repo gets `--no-verify`'d within a week.
- **Start from the ecosystem's recommended config**, nothing stricter. A strict ruleset lights
  up thousands of pre-existing errors and blocks every commit.
- **Don't gate on pre-existing violations.** Your change shouldn't be what makes their repo
  un-committable.

If they decline, match the surrounding file by hand and don't raise it again.

## Don't

- Don't run the formatter or the linter. Write the style; hand over the command.
- Don't reformat lines your change didn't touch.
- Don't change formatter or lint config to match your preference.
- Don't add a linter mid-task when one already exists but you dislike it.
- Don't commit the config change — hand it off ([`handoff.md`](handoff.md)).
