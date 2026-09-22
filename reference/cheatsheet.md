# Command cheatsheet

**Open when:** you know what you want but not the flag.
**Skip if:** you know the flag. Grep this file (`rg -n 'jq' reference/cheatsheet.md`) rather
than reading it top to bottom.

Tool-agnostic syntax — `rg`, `git`, `jq`, output bounding. Language-specific commands (test
one file, typecheck, format, deps) live in [`stack-commands.md`](stack-commands.md). The
judgment about *which* to reach for lives in `practices/`.

## ripgrep — search and file-finding

| Flag | Use |
| --- | --- |
| `-l` | paths only — the default first move |
| `-n` | line numbers; makes hits citable as `file:line` |
| `-t ts` / `-t py` / `-t go` | restrict by language; skips `dist/` for free |
| `-g '*.tsx'` / `-g '!**/test/**'` | include / exclude globs |
| `--files -g '**/foo*'` | find by filename; replaces `find`, honors ignore files |
| `-m 3` | stop after N matches per file — caps runaway output |
| `-C 2` | context lines; default to 0 |
| `-o` | print only the match, not the whole line |
| `--no-heading` | one `path:line:text` per row |
| `-i` / `-S` | case-insensitive / smart-case |
| `-F` | literal string, no regex escaping |
| `--stats` | counts without the matches |

```sh
rg -l 'parseConfig'                                  # which files
rg -n 'parseConfig' src/ --no-heading                # which lines
rg --files -g '**/*.config.*'                        # find by name
rg -n '^(export )?(async )?(class|function|const [A-Z]|def |func )' src/big.ts   # outline
rg -c 'TODO' -g '!node_modules' | head               # per-file counts
```

## Loud → quiet

| Loud | Quiet |
| --- | --- |
| `git status` | `git status --short` |
| `git diff` | `git --no-pager diff --stat` |
| `git log` | `git --no-pager log --oneline -10` |
| `find . -name X` | `rg --files -g '**/X*'` |
| `ls -R` / `tree` | `rg --files \| head -40` |
| `cat config.json` | `jq -r '.the.field' config.json` |
| `cat data.csv` | `head -3 data.csv` |
| whole test suite | scope to one file or one test — [`stack-commands.md`](stack-commands.md) |
| whole-repo compile | narrowest project scope, `2>&1 \| head -30` — same file |
| package install | add the tool's `--silent`/`-q` flag, or `> /dev/null` |
| `curl url` | `curl -s -o /dev/null -w '%{http_code}' url` |

## Bounding output

```sh
cmd 2>&1 | head -50                  # compilers/linters — they fail fast, errors on top
cmd 2>&1 | tail -30                  # test runners — the verdict is at the bottom
cmd > /dev/null 2>&1; echo $?        # you only need pass/fail
cmd > /tmp/out.log 2>&1; tail -30 /tmp/out.log   # long build; grep the file later
export GIT_PAGER=cat                 # git never paginates into context
```

## git — read commands

```sh
git status --short
git --no-pager log --oneline -10
git --no-pager diff --stat
git --no-pager diff -- src/auth/session.ts
git --no-pager diff -- . ':(exclude)*lock*' ':(exclude)*.snap'   # drop the noise
git --no-pager diff --name-only main...HEAD
git --no-pager log --oneline -5 -- path/to/file.ts
git --no-pager log -S 'functionName' --oneline        # when introduced/removed
git --no-pager log -1 --format='%h %an %ad %s' -L 42,48:src/foo.ts   # why this line
git --no-pager show --stat HEAD
git --no-pager diff --cached --stat                   # what you're about to commit
```

## Structured files — extract, don't read

```sh
jq -r '.scripts | keys[]' package.json
jq -r '.dependencies | to_entries[] | "\(.key)@\(.value)"' package.json | head -20
jq -r '.dependencies | keys[]' package-lock.json              # never read the lockfile
yq -r '.services | keys[]' docker-compose.yml
rg -n '^\[tool\.' pyproject.toml                              # section map
awk -F, 'NR<=3 {print} NR>3 {exit}' data.csv                  # shape of a CSV
head -c 400 big.json                                          # first bytes of anything
```
