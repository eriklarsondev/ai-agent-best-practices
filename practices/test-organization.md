# Test organization

**Open when:** writing a test, or adding an endpoint, module, or component that needs one.
**Skip if:** the repo has an established test layout — match it.

## The rule

**Tests live in their own tree, mirroring the source path.** Not scattered beside the code
they cover.

```
src/auth/refresh.py     →  tests/auth/test_refresh.py
src/api/handlers.py     →  tests/api/test_handlers.py
```

Why isolation wins: the source tree stays readable, the test/production boundary is
obvious to packaging and coverage tooling, and there's exactly one place to look for
"is this covered?" Mirroring the path means finding the test for a file is a mechanical
transform, not a search.

**Every new server-side endpoint ships with its own test file** at the mirrored path. No
endpoint merges untested — a hard requirement, not a nice-to-have. Cover the authorization
case explicitly: a caller who *shouldn't* reach it gets rejected. See
[`secure-coding.md`](secure-coding.md).

## Where the tree goes, per ecosystem

| Stack | Test root | Naming | Notes |
| --- | --- | --- | --- |
| **Python** | `tests/` | `test_*.py` | Mirror the package path; shared fixtures in `tests/conftest.py` |
| **JS / TS** | `tests/` mirroring `src/` | `*.test.ts` | Some repos use `__tests__/`; follow what's there |
| **Java / Kotlin** | `src/test/java/` | `*Test.java` | Mirrors `src/main/java/` — the build tool already enforces this |
| **C# / .NET** | separate `Foo.Tests/` project | `*Tests.cs` | One test project per source project |
| **Ruby** | `spec/` mirroring `app/`, `lib/` | `*_spec.rb` | Shared setup in `spec/spec_helper.rb` |
| **PHP** | `tests/` mirroring `src/` | `*Test.php` | PSR-4 autoload maps `Tests\` to `tests/` |
| **Elixir** | `test/` mirroring `lib/` | `*_test.exs` | Shared setup in `test/test_helper.exs` |
| **Swift** | `Tests/<Module>Tests/` | `*Tests.swift` | SwiftPM convention |

### Two toolchain exceptions — don't fight them

- **Go** requires `foo_test.go` to sit in the *same directory* as `foo.go`. That's a
  compiler rule, not a style preference. Keep unit tests colocated; put cross-package
  integration tests under `tests/` or a dedicated `_test` package.
- **Rust** puts unit tests inline via `#[cfg(test)] mod tests` and integration tests in
  `tests/` at the crate root. Same reasoning — follow the toolchain.

Everywhere else, isolate.

## Subdivide by kind, once there's more than one kind

```
tests/
  unit/          fast, no I/O, no network
  integration/   real database, real HTTP boundary
  e2e/           full stack
  fixtures/      sample payloads, seed data
  helpers/       shared builders and factories
```

Don't create these folders up front. A flat `tests/` is right until a second kind of test
appears — see [`code-restraint.md`](code-restraint.md).

## Fixtures and helpers

- Shared setup goes in the ecosystem's conventional file (`conftest.py`,
  `spec_helper.rb`, `test_helper.exs`, a `TestBase` class).
- Test data lives under `tests/fixtures/` — never committed into a source directory.
- **Production code never imports from the test tree.** If a helper is useful to both, it
  belongs in source, not tests.

## Don't

| Don't | Instead |
| --- | --- |
| Drop a test file beside the source file (outside Go/Rust) | Mirrored path in the test tree |
| One giant test file per module | One per behavior or scenario — [`file-organization.md`](file-organization.md) |
| Commit fixture data into `src/` | `tests/fixtures/` |
| Name a test after the function (`test_refresh`) | Name it after the case (`test_refresh_rejects_replayed_token`) |
| Skip, `xfail`, or `.only` a test to move on | Say in the handoff that you're unsure |

And don't run them — writing is yours, executing is the developer's
([`verification.md`](verification.md)).
