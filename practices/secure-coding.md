# Secure coding

**Open when:** adding or changing a route, handler, or endpoint · touching an auth check ·
building a query · accepting user input · writing something to a log.
**Skip if:** pure refactor with no behavior change.

## Every new endpoint answers three questions

Before it's done, you can state: **who may call it**, **what is validated**, **what it
leaks**. If you can't answer all three, it isn't finished — and a test file doesn't cover
for a missing answer.

## Authorization, not just authentication

The most common real vulnerability in generated code isn't exotic. It's a route that checks
*logged in* and forgets *allowed to touch this record*.

```
✗  GET /orders/:id  → returns the order
✓  GET /orders/:id  → returns the order if it belongs to the caller (or they're staff)
```

- **Any route taking an ID must prove the caller owns it.** Scoping the query
  (`WHERE id = ? AND user_id = ?`) beats fetching then comparing — it can't be forgotten in
  a later refactor.
- **Match how sibling routes do it.** If every handler goes through a `require_role`
  decorator or middleware, yours does too — see [`consistency.md`](consistency.md).
- **Default deny.** A new route with no auth annotation should fail closed, not open. If the
  framework defaults the other way, say so in the handoff.

## The rest of the checklist

| Concern | Rule |
| --- | --- |
| **Injection** | Parameterize. Never build SQL, shell, LDAP, or NoSQL by string concatenation or interpolation — not even for "internal" values |
| **Input validation** | Validate shape, type, range, and length **once, at the trust boundary** (handler, queue consumer, webhook, CLI arg). Then trust it inward |
| **Output encoding** | Context-specific and framework-provided. HTML-escape for HTML, not for JSON. Never hand-roll an escaper |
| **Path handling** | User input never concatenates into a filesystem path. Resolve and verify it's inside the intended root |
| **Outbound URLs** | A URL from user input that your server fetches is SSRF. Allowlist the host |
| **Deserialization** | Never deserialize untrusted input into arbitrary types (`pickle`, Java native, `yaml.load`). Use the safe loader |
| **Mass assignment** | Bind request bodies to an explicit field list, never straight onto a model |
| **Secrets** | Read from config/env. Never literal in code, tests, or fixtures |

## Never log

Secrets, tokens, passwords, auth headers, session IDs, full card or account numbers, request
bodies at auth endpoints, or PII beyond an opaque ID.

Log the correlation ID and the *shape* of what happened — not the payload. A log line is
the easiest place to leak a credential, because nobody reviews logs the way they review code.

## Errors: detail inward, generic outward

The client gets a generic message plus a reference ID. The log gets the detail. A stack
trace or raw DB error in an HTTP response is a free map of your internals.

```
✗  500  {"error": "column users.ssn does not exist"}
✓  500  {"error": "Internal error", "ref": "a1b2c3"}   # detail in the log under a1b2c3
```

## What isn't yours

Running scanners, dependency audits, or pen tests — that's execution
([`running-things.md`](running-things.md)). Reading a scan report they paste back *is* yours.

## Flag it in the handoff

Any change to an auth path, a trust boundary, or anything touching credentials gets named
explicitly — even when you're confident. Security regressions are the class where a reviewer
most needs to know where to look, and the class where "it compiles" means least.
