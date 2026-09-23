# PR description format

**Open when:** the developer asks you to write a PR description.
**Skip if:** they didn't ask — never open a PR yourself ([`../boundaries.md`](../boundaries.md)).

You write the description. The developer opens the PR, reviews it, and merges it.

## Format rules

- **Markdown, no hard line breaks.** Each paragraph and each bullet is one continuous
  line — let the renderer wrap it. Hard-wrapped prose reflows badly in PR editors and
  review diffs.
- **Headings start at `####`.** Never `#`, `##`, or `###`. The PR title is already the
  page's top-level heading; anything larger than `####` renders as shouting beside it.
- **Summary first, highlights second.** Nothing before the summary — no preamble, no
  restating the ticket title, no "This PR…".
- **Group highlights by stack layer**, in this order: server-side → client-side →
  infrastructure. Omit any layer the change doesn't touch; never leave an empty heading.
- **No file-by-file tour.** The diff is right there. A bullet says what changed and what
  it affects, not which lines moved.
- **Flag what a reviewer must act on** — a new error case to handle, a migration to run,
  a config value to set. That's the part they can't get from reading the diff.

## Shape

```
<One line, 2-4 sentences: what changed and why. Short but comprehensive — a reviewer
should know the shape of the change before opening the diff.>

#### Server-side
- …

#### Client-side
- …

#### Infrastructure
- …

#### Verification
- …
```

The summary and the stack-grouped highlights are required. `#### Verification` is
strongly recommended — see [`../practices/handoff.md`](../practices/handoff.md) — but
follow the repo's convention if it has one.

## Example

```
Refresh tokens now rotate on every use, and a replayed token fails closed instead of silently issuing a new pair. The revocation check moved ahead of the expiry check, so a stolen token is rejected even inside its validity window. Existing sessions are unaffected and pick up rotation on their next refresh.

#### Server-side
- `refresh()` rotates the refresh token and revokes the previous one on success.
- Revocation now runs before the expiry check, so a replayed token returns 401 rather than a fresh pair.
- New `AuthError.Replayed` — anything matching exhaustively on the error enum needs a branch for it.

#### Client-side
- The token store persists the rotated refresh token before the response resolves; a failed write clears the session rather than leaving a stale token behind.
- Sign-out flow unchanged.

#### Infrastructure
- Migration `0042_token_family.sql` adds a nullable `token_family` column. No backfill needed — rows populate on next refresh.

#### Verification
- `rg -n 'refresh_token\('` confirms all 4 call sites updated. Added `tests/auth/test_refresh.py` (3 cases); nothing was run — `mypy auth/ && ruff check auth/`, then `pytest tests/auth/test_refresh.py -q`. Worth exercising login on two devices, then refreshing the older session.
```

## Adapting the grouping

Server / client / infrastructure is the default triad. Match the repo's actual shape when
it differs — a monorepo may group by package, a backend-only service by module, a library
by public surface vs. internals. The point of the grouping is that a reviewer can skip
straight to the layer they own.
