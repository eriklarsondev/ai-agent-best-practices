# Workflow: dependency changes

**Open when:** you've been asked to add, remove, or upgrade a dependency.
**Skip if:** you weren't asked — adding a dependency as a side effect of another task is out
of bounds. See [`../boundaries.md`](../boundaries.md).

Per-ecosystem list/add commands and lockfile names:
[`../reference/stack-commands.md`](../reference/stack-commands.md).

## Before adding anything

1. **Is it already there?** List the declared dependencies — don't read the manifest whole.
2. **Does something already installed do it?** Most repos already ship a date library, an
   HTTP client, and a validation library.
3. **Is it ~20 lines?** Write the 20 lines. See
   [`../practices/code-restraint.md`](../practices/code-restraint.md).

If you still need it, propose it with the reason and let the developer decide. Don't install
first and mention it after.

## Upgrading

Find the current constraint from the manifest — a local read, no network:

```sh
jq -r '.dependencies["pkg"]' package.json     # JS/TS
rg -n 'pkg' pyproject.toml                    # Python
rg -n 'pkg' go.mod                            # Go
rg -n 'pkg' Cargo.toml                        # Rust
rg -n -A2 'artifactId>pkg' pom.xml            # Java
```

For what's *latest*, ask rather than query. `npm view`, `pip index versions`,
`go list -m -versions`, and `cargo search` are network calls to a registry, and the developer
can answer in one line — or already knows, because that's why they asked.

Read the **migration guide or breaking-changes section**, not the whole changelog. Then
measure your own exposure — this list *is* the work:

```sh
rg -n "from ['\"]pkg|require\(['\"]pkg" --no-heading | head -40   # JS/TS
rg -n '^\s*(from|import) pkg' --no-heading | head -40             # Python
rg -n 'example\.com/pkg' --no-heading | head -40                  # Go
rg -n 'use pkg::' --no-heading | head -40                         # Rust
rg -n 'import com\.pkg' --no-heading | head -40                   # Java
```

If it's large, upgrade in one pass and verify in one pass — don't interleave.

## The lockfile

- Let the package manager write it. Never hand-edit, never read it.
- Exclude it when you diff: `git --no-pager diff -- . ':(exclude)*lock*'`
- Commit it (when asked to commit at all) — it's the reproducibility contract.

## Verify

Your side is the exposure list from the greps above, re-read against the breaking-changes
notes. Little else here is checkable by reading, which makes the handoff unusually
load-bearing — say so rather than implying more confidence than you have.

A transitive change can break anything, so hand over more than usual: **install, then
typecheck, then build, then the full suite**, in that order, per stack in
[`../reference/stack-commands.md`](../reference/stack-commands.md). Ask them to boot the app
once too — dependency breakage often shows at module load, where unit tests never look
([`../practices/verification.md`](../practices/verification.md)).

## Report

Old version → new version, why, what broke and how you fixed it, what you ran. Flag anything
you couldn't verify — a major upgrade with a passing suite is still not a guarantee.

## Never

- Upgrade unrelated packages while you're in there.
- Run a blanket auto-fix that takes majors (`npm audit fix --force` and friends).
- Add a dependency to make a test pass.
- Publish anything. See [`../boundaries.md`](../boundaries.md).
