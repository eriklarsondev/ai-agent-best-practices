# Workflow: refactoring

**Open when:** changing structure without changing behavior.
**Skip if:** behavior is changing — that's a feature or a fix.

## 0. Was this asked for?

Refactoring adjacent to your actual task is scope creep, and it buries the change the
developer wanted in a diff they now have to review. Note it in one sentence instead.

## 1. Pin behavior first

A refactor with no test is a rewrite with extra steps. Before touching anything, confirm
coverage **exists** for the behavior you're about to move — grep the test tree for it:

```sh
rg -l 'refresh_token|RefreshToken' tests/
```

If it's missing, write it first. Then ask the developer to run it *before* you start, so
there's a known-green baseline:

> There's no coverage for token rotation — I added `tests/auth/test_refresh.py`. Worth
> running it before I refactor, so we know it was green going in.

That baseline is the entire safety margin. Without it you're restructuring on faith.

## 2. Enumerate the blast radius — grep, don't read

```sh
rg -n 'oldName\b' --no-heading                 # every reference
rg -n 'oldName' -g '*.md' -g '*.json' -g '*.yml'   # docs, configs, fixtures
rg -n 'from .*module-name|require\(.*module-name' # import sites
```

Count the hits before you start. Twelve is a task; two hundred is a different plan
(mechanical tooling, or a subagent sweep — see
[`../practices/delegation.md`](../practices/delegation.md)).

Watch for references that grep by symbol misses: string-based DI keys, dynamic imports,
serialized class names, database column names, API field names, feature flag keys.

## 3. One mechanical change at a time

Rename, *then* move, *then* extract — never all three in one pass. Each step should leave the
tests green. A broken intermediate state where you can't tell which of three changes caused
the failure is where refactors go to die.

For pure renames, prefer the tool over hand edits:

```sh
rg -l 'oldName' | xargs sed -i '' 's/\boldName\b/newName/g'   # macOS
```

Verify with `rg -n 'oldName'` returning nothing, not by re-reading files.

## 4. Keep the diff readable

- Don't reformat lines you didn't change. Formatting churn mixed into a refactor makes review
  impossible and doubles the token cost.
- Move code in one commit's worth of work, change it in another. A diff that both moves and
  edits shows as wholesale deletion and addition.

## 5. Grep after every step, then ask for a wide run

`rg -n 'oldName'` after **each** mechanical step, not just at the end. For a rename that's a
complete check — nothing left to find *is* the proof — and it stops a broken intermediate
state from compounding, for about 50 tokens a step.

Then ask for a wider run than usual. Structural changes reach places targeted tests don't, so
this is the one case where the **full suite** is worth the developer's time rather than a
subset:

> Rename is done across 14 files; `rg -n 'oldName'` now returns nothing. Worth running `mypy`
> and then the whole suite rather than just `tests/auth` — a rename touches things the
> targeted tests won't reach.

## 6. Report

What moved and why, the before/after shape in two lines, what you ran. If you found behavior
that was already wrong, say so — don't silently fix it inside a refactor, where it's invisible.
