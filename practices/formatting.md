# Formatting and lint tooling

**Open when:** you're about to format code, or you notice the repo has no formatter.
**Skip if:** you already know the repo's formatter and have run it.

Every stack has the same three pieces — a **formatter**, a **linter**, and a **pre-commit
hook that runs both on staged files**. Only the tool names change.

## Detect before you type

```sh
rg --files -g '.prettierrc*' -g '.editorconfig' -g 'biome.json' -g 'ruff.toml' \
          -g '.golangci.yml' -g 'rustfmt.toml' -g '.rubocop.yml' -g '.pre-commit-config.yaml' \
          -g '.husky' -g '.githooks' -d 2
rg -n 'prettier|eslint|biome|husky|\[tool\.ruff\]|spotless|ktlint|rubocop|php-cs-fixer' \
   package.json pyproject.toml build.gradle pom.xml Gemfile composer.json 2>/dev/null
```

**Tooling exists** → run it. Never match style by eye when a tool already decides it, and
never argue with its output.

## Scope: only the files you touched

A repo-wide reformat buries the change under thousands of lines of churn, makes review
impossible, and destroys blame. If the repo genuinely needs one, say so — it's its own
commit, and it's the developer's call.

## Nothing configured at all → recommend the package

Stop. Don't hand-format across an unformatted repo, and don't install anything silently.
Recommend all three together — they're one workflow, and each is weaker alone:

> No formatting or lint setup here. Want me to add a formatter, a linter, and a pre-commit
> hook that runs both on staged files? The hook only touches what you're committing, so
> commits stay fast. I'd format just the files this change touches.

They may take a subset — install only what they agreed to. Agreement makes this a
**sanctioned exception** to the no-new-dependencies rule in
[`../boundaries.md`](../boundaries.md), scoped to this, this once.

### The commit flow, in every stack

1. Developer stages their changes
2. `git commit` fires the hook
3. **Linter** runs on staged files with its autofix flag
4. **Formatter** runs on the result
5. Fixes are re-staged
6. The commit completes — or aborts, if the linter hit something it can't auto-fix

**Linter before formatter, always.** Both rewrite formatting and whichever runs last wins;
putting the formatter last means they never fight over the same lines.

### Per-stack tooling

| Stack | Formatter · Linter | Hook runner |
| --- | --- | --- |
| **JS / TS** | Prettier · ESLint (or **Biome** for both in one) | Husky + `lint-staged` |
| **Python** | `ruff format` · `ruff check --fix` | `pre-commit` |
| **Go** | `gofmt` · `golangci-lint` — both ship with the toolchain | `pre-commit` or `.githooks` |
| **Rust** | `cargo fmt` · `cargo clippy` — both ship with the toolchain | `pre-commit` or `.githooks` |
| **Java / Kotlin** | Spotless · Checkstyle / ktlint / detekt | Gradle/Maven `pre-commit` plugin |
| **C# / .NET** | `dotnet format` · built-in analyzers | `pre-commit` or `.githooks` |
| **Ruby** | `rubocop -a` (both) | `overcommit` or `pre-commit` |
| **PHP** | `php-cs-fixer` · `phpstan` / `phpcs` | `captainhook` or `pre-commit` |

Go and Rust need no permission for formatting — nothing to install.

### JS/TS setup, in full

```sh
npm i -D --save-exact prettier eslint husky lint-staged
npx husky init
echo 'npx lint-staged' > .husky/pre-commit
```

```jsonc
// package.json — array order is execution order: ESLint, then Prettier
"lint-staged": {
  "*.{ts,tsx,js,jsx}": ["eslint --fix", "prettier --write"],
  "*.{json,css,md}": ["prettier --write"]
}
```

## Three things that decide whether this survives

- **Staged files only, never the whole repo.** A hook that lints everything gets
  `--no-verify`'d within a week.
- **Start from the ecosystem's recommended config**, nothing stricter. A strict ruleset on
  an existing codebase lights up thousands of pre-existing errors and blocks every commit.
- **Don't gate on pre-existing violations.** Your change shouldn't be the thing that makes
  their repo un-committable.

If they decline, match the surrounding file by hand and don't raise it again.

## Don't

- Don't reformat lines your change didn't touch.
- Don't change formatter or lint config to match your preference.
- Don't add a linter mid-task when one already exists but you dislike it.
- Don't commit the config change — hand it off ([`handoff.md`](handoff.md)).
