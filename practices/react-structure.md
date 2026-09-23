# React structure

**Open when:** adding or growing a component in a React codebase.
**Skip if:** it isn't React, or you're making a small edit to an existing component.

General file rules in [`file-organization.md`](file-organization.md). This is the
component-specific layer.

## One file, or one folder

A component that needs **one** file stays one file, beside its siblings: `UserCard.tsx`.

The moment it needs a **second** file — a subcomponent, a hook, local types, styles, its test
— give it a folder named for the component and colocate everything it owns:

```
UserCard/
  UserCard.tsx         the component — the only thing imported from outside
  UserCardAvatar.tsx   subcomponent, used only here
  use-user-card.ts     local hook: fetching, form state
  types.ts             props and local types, once they outgrow the component file
```

Its test lives in the test tree at the mirrored path —
`tests/components/UserCard.test.tsx`, not inside the folder. See
[`test-organization.md`](test-organization.md).

- **Don't pre-create the folder.** One file until a second is genuinely needed.
- **One public export.** The folder exposes the component; internals stay internal. A single
  `index.tsx` re-exporting just that component is fine if the repo already does that — follow
  what's there, and don't add barrels that re-export everything.
- **Ownership follows use.** Anything only this component uses lives in its folder. When a
  second component needs it, move it up to the nearest shared parent — not to a global
  `utils/`.

## Keep the component under ~150 lines

Three extractions, in the order to reach for them:

1. **Markup → subcomponents.** A nested block with its own conditional logic is a component.
2. **Logic → a hook.** Fetching, form state, subscriptions, derived state. `use-user-card.ts`
   next to the component.
3. **Constants and pure helpers → a sibling file.** Not a global utils dump.

What's left should read as composition: props in, hooks called, markup out.

## Colocation over centralization

Put a component next to the route or feature that uses it. Promote it to a shared
`components/` directory only when a **second** consumer appears — not in anticipation of one.

**Next.js App Router:** colocate inside the route segment (`app/dashboard/UserCard/`), and
promote upward only when another segment needs it. Keep `page.tsx`, `layout.tsx`, and
`route.ts` at the names the framework expects.

## Accessibility is part of "done"

Not a follow-up ticket. The cheap ones, which cover most of it:

- **Semantic element first.** `<button>` before a `<div onClick>`; `<nav>`, `<main>`,
  `<label>`. You get keyboard and screen-reader behavior for free and can't forget it later.
- **Every input has a label** — a real `<label htmlFor>`, not a placeholder.
- **Interactive means focusable.** If you handle `onClick`, it takes keyboard focus and
  responds to Enter/Space. Never remove focus outlines without replacing them.
- **Images carry `alt`** — empty `alt=""` when decorative, which is a decision, not an
  omission.
- **State is announced, not just colored.** An error needs text or `aria-invalid`, not only
  a red border.

`aria-*` is the fallback when no semantic element fits — reach for it second, not first.
Flag in the handoff anything you couldn't verify without running it.

## Follow what's there

If the repo already has a convention — flat `components/` with one file each, feature folders,
atomic design, `.module.css` beside each component — match it. Framework and repo convention
outrank this file. See [`consistency.md`](consistency.md).

## Check the offenders — only if asked

```sh
rg --files -g '*.tsx' | xargs wc -l | sort -rn | head -15
```
