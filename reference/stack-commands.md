# Stack commands

**Open when:** you're in a stack whose narrow test / check / format commands you don't know.
**Skip if:** the repo's `AGENTS.md` lists them — that always wins.

Grep for your stack (`rg -A6 'Python' reference/stack-commands.md`) rather than reading it
all. Tool-agnostic commands (`rg`, `git`, `jq`, output bounding) are in
[`cheatsheet.md`](cheatsheet.md).

## Find the task list first

Every ecosystem keeps its commands in a manifest. Extract the task section; don't read the
file.

```sh
jq -r '.scripts' package.json                  # JS/TS
rg -n '^\[tool\.|^\[project\.scripts\]' pyproject.toml   # Python
rg -n '^[a-z-]+:' Makefile | head -20          # anything with a Makefile
rg -n '<target|<goal|task ' build.gradle build.xml pom.xml 2>/dev/null
rg -n '^\[\[bin\]\]|^\[workspace\]' Cargo.toml # Rust
rg --files -g 'justfile' -g 'Taskfile*' -g 'Makefile' -g 'mise.toml'
```

## The narrow commands

**Every column here is a command you hand over, not one you run**
([`../practices/verification.md`](../practices/verification.md)). This file exists so the
handoff contains an exact invocation rather than one the developer has to derive — order them
cheapest-failure-first: typecheck, lint, then the single test file.

| Stack | Test one file / one test | Compile / typecheck | Format · Lint |
| --- | --- | --- | --- |
| **JS / TS** | `npm test -- path/f.test.ts` · `vitest run path` | `tsc --noEmit --pretty false` | `prettier --write` · `eslint --fix` |
| **Python** | `pytest path/test_x.py::test_name -q` | `mypy path/` · `pyright` | `ruff format` · `ruff check --fix` |
| **Go** | `go test ./pkg -run TestName` | `go build ./...` · `go vet ./pkg` | `gofmt -w` · `golangci-lint run` |
| **Rust** | `cargo test test_name` | `cargo check --message-format=short` | `cargo fmt` · `cargo clippy` |
| **Java (Maven)** | `mvn -q test -Dtest=ClassName#method` | `mvn -q compile` | `mvn spotless:apply` · `mvn checkstyle:check` |
| **Java (Gradle)** | `gradle test --tests '*ClassName.method'` | `gradle compileJava` | `gradle spotlessApply` · `gradle check` |
| **Kotlin** | `gradle test --tests '*ClassName*'` | `gradle compileKotlin` | `ktlint -F` · `detekt` |
| **C# / .NET** | `dotnet test --filter FullyQualifiedName~Name` | `dotnet build -v q` | `dotnet format` · analyzers in build |
| **Ruby** | `bundle exec rspec path/x_spec.rb:42` | — (`ruby -c` parses only) | `rubocop -a` |
| **PHP** | `vendor/bin/phpunit --filter testName path` | `vendor/bin/phpstan analyse` | `vendor/bin/php-cs-fixer fix` · `phpcs` |
| **Elixir** | `mix test path/x_test.exs:42` | `mix compile --warnings-as-errors` | `mix format` · `mix credo` |
| **Swift** | `swift test --filter TestName` | `swift build` | `swift-format -i` · `swiftlint` |

If the developer explicitly asks you to run one, bound it: `2>&1 | head -30` for compilers
(they fail fast, errors on top), `2>&1 | tail -20` for test runners (verdict at the bottom).

## Dependencies

| Stack | List | Add (only when asked) | Lockfile — never read it |
| --- | --- | --- | --- |
| **JS / TS** | `jq -r '.dependencies \| keys[]' package.json` | `npm i -E pkg` · `pnpm add -E pkg` | `package-lock.json` · `pnpm-lock.yaml` |
| **Python** | `rg -n '^dependencies' -A20 pyproject.toml` | `uv add pkg` · `poetry add pkg` | `uv.lock` · `poetry.lock` |
| **Go** | `rg -n '^\t' go.mod \| head -30` | `go get pkg` | `go.sum` |
| **Rust** | `rg -n '^\[dependencies\]' -A30 Cargo.toml` | `cargo add pkg` | `Cargo.lock` |
| **Java** | `rg -n '<artifactId>' pom.xml \| head -30` | edit `pom.xml` / `build.gradle` | `gradle.lockfile` |
| **C# / .NET** | `rg -n 'PackageReference' *.csproj` | `dotnet add package Pkg` | `packages.lock.json` |
| **Ruby** | `rg -n '^gem ' Gemfile` | edit `Gemfile`, `bundle install` | `Gemfile.lock` |
| **PHP** | `jq -r '.require \| keys[]' composer.json` | `composer require pkg` | `composer.lock` |

## Never read

Alongside lockfiles: `node_modules/` · `vendor/` · `.venv/` · `target/` · `build/` ·
`dist/` · `bin/` · `obj/` · `_build/` · `.gradle/` · `__pycache__/` · `*.min.*` ·
`__snapshots__/` · generated clients and protobuf output.

Most are already in `.gitignore`, so `rg` skips them for free — which is why
`rg --files -g` beats `find`.
