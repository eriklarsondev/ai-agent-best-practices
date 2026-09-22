# File organization

**Open when:** a file you're editing is approaching ~150 lines, or you're adding a new one.
**Skip if:** you're making a small edit to a file that's already well-sized.

## The target

**150 lines per file.** Not a lint rule — a design signal. A file past it is almost always
doing more than one thing, and the fix is to name the second thing and move it out.

Why this number matters more for agent-maintained code than human code:

- A 150-line file is ~2k tokens. An agent reads it **whole**, cheaply, and edits it with full
  knowledge of what's in it.
- A 900-line file forces partial reads. Every edit made from a partial view is an edit made
  without knowing what else is in there — which is where duplicated helpers, broken
  invariants, and contradictory branches come from.
- Small files produce small diffs, clean blame, and fewer merge conflicts.

## Split by topic, never by line count

Cutting a 300-line file at line 150 produces two bad files. Find the **second
responsibility** and extract that.

| Symptom | The split |
| --- | --- |
| Handler does routing, validation, logic, and SQL | `route.ts` · `schema.ts` · `service.ts` · `repository.ts` |
| Component renders, fetches, and holds form state | component · `use-thing.ts` hook · subcomponents |
| Module has 12 exports | One file per concept, grouped in a directory |
| Helpers only this module uses | `./helpers.ts` beside it — not a global `utils/` |
| Types used by three files | `types.ts` in the shared parent. Used by one? Keep them local |
| Test file covering six scenarios | One file per scenario — layout in [`test-organization.md`](test-organization.md) |
| Giant `switch` or config map | A data file the logic reads |

Each resulting file should have a name that says exactly what's in it. If you can't name it,
the split is wrong.

## The framework decides the layout

Framework convention **outranks** this guidance and outranks your preference. Put things
where the framework expects them:

- **Next.js App Router** — `page.tsx`, `layout.tsx`, `route.ts`; colocate components with
  the route that uses them; shared ones move up.
- **Django** — per-app `models.py`, `views.py`, `serializers.py`, `urls.py`. Split into a
  package (`views/`) when one grows.
- **Rails** — MVC directories; concerns for shared behavior.
- **Go** — package per domain; `foo.go` beside `foo_test.go`; small packages, no `utils`.
- **Terraform** — per module: `main.tf`, `variables.tf`, `outputs.tf`, `versions.tf`.

Check before inventing: `rg --files -d 3 | head -40` shows you the shape the repo already
has. Match it — see [`consistency.md`](consistency.md).

React components have their own layout rules — one file until a second is needed, then a
folder named for the component: [`react-structure.md`](react-structure.md).

## Don't overcorrect

Splitting has its own costs. Avoid:

- A directory containing one file.
- Directory-wide `index.ts` barrels that re-export everything — they hide structure, slow
  tooling, and create import cycles. (A folder's single-component entry point is not this.)
- Extracting a "helper" called once, in one place. Inline is clearer.
- Splitting files that are genuinely one cohesive thing (a state machine, a parser) into
  fragments that can only be understood together.
- Layers of indirection to hit a line count. Two well-named 200-line files beat six
  40-line files that call each other.

The target is legibility. If a split makes the code harder to follow, it was the wrong split.

## Fine to exceed 150

Generated files · lockfiles · large static data or config maps · migrations · a single
cohesive algorithm with a stated invariant. Say so if you're leaving one long on purpose.

## Inheriting a 900-line file

Don't refactor it as a side effect of an unrelated task — that's scope creep, and it buries
the change the developer asked for. Options, in order:

1. Make your change in place, in the right section.
2. If your change would add substantial new surface, extract **just that** into a new file.
3. If the file genuinely needs splitting, say so in one sentence and let the developer decide.

## Find the offenders

```sh
rg --files -g '*.ts' -g '*.tsx' | xargs wc -l | sort -rn | head -20
```
