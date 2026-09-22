# Migrations and contract changes

**Open when:** writing a database migration or changing an API contract.
**Skip if:** neither.

## You write it, they run it — so the care is all front-loaded

Everywhere else, a mistake surfaces when something fails. Here it surfaces in production,
against real data, with no undo. You get zero execution feedback
([`running-things.md`](running-things.md)), so read your migration back as if reviewing
someone else's.

## Expand and contract — never one destructive step

Each arrow is a separate migration, usually a separate deploy:

| Change | Sequence |
| --- | --- |
| **Add a column** | Add it **nullable**, with no table-rewriting default |
| **Rename a column** | Add new → backfill → write both → switch reads → drop old |
| **Drop a column** | Stop reading it → deploy → drop in a later migration |
| **Change a type** | Add new column → backfill → switch → drop old |
| **Add a constraint** | Add as `NOT VALID` → validate separately |
| **Add an index** | Concurrently, on its own, never inside a bigger migration |

The tempting one-step version is the one that takes the site down. If a rename looks like a
two-line migration, that's the signal to slow down, not to proceed.

## Never edit a shipped migration

Once it has run in anyone's environment — including a teammate's laptop — it's immutable.
Editing it makes their schema silently diverge from the file that claims to describe it.
Fix forward with a new migration, always.

## Lock awareness — flag it, every time

Name what the migration locks and roughly how long, because the developer running it can't
see that from the filename. The usual offenders:

- Adding an index **without** `CONCURRENTLY`
- Adding a foreign key without `NOT VALID`
- Changing a column type (rewrites the table)
- Adding `NOT NULL` to an existing column
- Any `UPDATE` touching every row

> `0042_add_token_family.sql` — nullable column add, no rewrite, sub-second. The backfill is
> separate (`0043`) and batched; it'll take a few minutes on prod volume.

## Backfills are separate, batched, and resumable

Never inside the schema migration. Loop in bounded chunks, commit per chunk, and make
re-running safe. A backfill that must run to completion in one transaction on a large table
is a backfill that will be killed halfway.

**Never delete rows in a schema migration.** Data removal is its own reviewed change — see
[`../boundaries.md`](../boundaries.md).

## Reversibility

Write the `down` — or state plainly that there isn't one and why. "Irreversible" is an
acceptable answer; a `down` that silently loses data is not.

## API contracts: additive is safe, everything else isn't

| Safe | Breaking |
| --- | --- |
| Adding an optional request field | Making an optional field required |
| Adding a response field | Removing or renaming a response field |
| Accepting a new enum value | Returning a new enum value clients must handle |
| Widening what you accept | Narrowing what you return, or changing a type |

For anything in the right column: version it, or deprecate with a window. And remember
consumers you can't see — a mobile client shipped last month is still calling the old shape.

Grep before you change a response: `rg -n 'fieldName'` across clients, tests, and fixtures.

## Every migration gets named in the handoff

What it does, what it locks, how long, whether it reverses, and whether a backfill follows.
Never let one ride along unmentioned in a list of changed files.
