# Doc comments by language

**Open when:** writing a doc comment on a server-side function and you want the right format.
**Skip if:** the file already has doc comments — match those.

Grep for your language rather than reading the whole file. Policy — *when* to write one at
all — is in [`../practices/comments.md`](../practices/comments.md).

## Use the language's own convention

Never import one language's habits into another.

| Language | Convention | Marker |
| --- | --- | --- |
| JS / TS | **JSDoc** | `/** */` |
| PHP | **PHPDoc** | `/** */` with `@param`, `@return`, `@throws` |
| Python | **Docstrings** (PEP 257) | `"""..."""` — Google, NumPy, or reST style |
| Go | **GoDoc** | `//` starting with the identifier name |
| Rust | **rustdoc** | `///`, with `# Errors` / `# Panics` / `# Safety` |
| Java / Kotlin | **Javadoc** / **KDoc** | `/** */` |
| C# | **XML doc comments** | `/// <summary>` |
| Ruby | **YARD** (or RDoc) | `#` with `@param` / `@return` |
| Swift | **Markup** | `///` with `- Parameter:` / `- Throws:` |

## How much to write depends on the type system

**Statically typed** — TS, Go, Rust, Java, C#, Kotlin, Swift:
never restate a type. The signature already says it. Document only what it *can't*: units,
nullability semantics, side effects, thrown errors, idempotency, ordering requirements.

**Dynamically or gradually typed** — PHP, Python, Ruby, plain JS:
the `@param` / `@return` type tags carry real information and are often the only contract a
caller has. Write them.

In both cases: no tag that merely restates the parameter name (`@param $name The name.`). If
every tag would be redundant, the one-line summary **is** the correct doc comment.

## Shapes

```ts
/**
 * Exchanges a refresh token for a new access token pair.
 * Rotates the refresh token — the old one is revoked on success.
 *
 * @throws {AuthError} when the token is expired, revoked, or replayed.
 */
```

```php
/**
 * Exchanges a refresh token for a new access token pair.
 * Rotates the refresh token — the old one is revoked on success.
 *
 * @param  non-empty-string $refreshToken
 * @return array{access: string, refresh: string}
 * @throws AuthException When the token is expired, revoked, or replayed.
 */
```

```python
def exchange_refresh_token(token: str) -> TokenPair:
    """Exchange a refresh token for a new access token pair.

    Rotates the refresh token — the old one is revoked on success.

    Raises:
        AuthError: If the token is expired, revoked, or replayed.
    """
```

```go
// ExchangeRefreshToken exchanges a refresh token for a new access token pair.
// It rotates the refresh token; the old one is revoked on success.
// Returns ErrTokenReplayed if the token has already been used.
```

```rust
/// Exchanges a refresh token for a new access token pair.
///
/// Rotates the refresh token — the old one is revoked on success.
///
/// # Errors
/// Returns [`AuthError::Replayed`] if the token has already been used.
```

Note the Go form: the comment **starts with the identifier name** and is a full sentence.
That's not stylistic — `go doc` and `golint` both depend on it.

## Where they go

On the **exported surface**: public functions, methods, types, and modules. Trivial private
helpers get nothing. A one-line summary on a well-named private function is noise.

## Tooling that enforces it

Check before hand-writing; the repo may already have a linter with opinions.

```sh
rg -n 'jsdoc|phpcs|pydocstyle|D1[0-9][0-9]|missing-docstring|revive|golint' \
   package.json .eslintrc* pyproject.toml ruff.toml phpcs.xml .golangci.yml 2>/dev/null
```
