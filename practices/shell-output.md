# Shell output discipline

**Open when:** before running a command whose output size you can't predict.
**Skip if:** the command is already bounded (`-l`, `--stat`, `head`, a known-short script).

Mostly this applies to `rg` and git, since those are the only things you run
([`running-things.md`](running-things.md)). The rest of this file is for the exception: the
developer asked you to run something.

## The rule

Every command is 100k tokens until you've bounded it. Bound it at the call site — you can't
un-read output.

```sh
cmd 2>&1 | head -50          # compilers, linters: they fail fast, errors are at the top
cmd 2>&1 | tail -30          # test runners: the summary is at the bottom
cmd > /dev/null 2>&1; echo $?   # you only need pass/fail
cmd > /tmp/out.log 2>&1; tail -30 /tmp/out.log   # long build; grep the file later if needed
```

Choosing `head` vs `tail` matters: a `tsc` run puts the first real error at the top and
thousands of cascading ones after it; `pytest`/`vitest` put the verdict at the bottom.

## Quiet forms

The loud → quiet table and the `jq`/`yq`/`awk` extraction recipes live in
[`../reference/cheatsheet.md`](../reference/cheatsheet.md). Set `GIT_PAGER=cat` once and git
never paginates into your context again.

The general move for structured files — JSON, YAML, TOML, CSV — is **extract, don't read**.
Pull the one field; never open the file.

## Long-running commands

Redirect to a file and read the tail; don't hold a stream open in context. The artifact on
disk means you can grep it for the one error line instead of re-running the command.

```sh
npm run build > /tmp/build.log 2>&1; tail -30 /tmp/build.log
rg -n 'error|ERR!' /tmp/build.log | head -10
```

Better still: don't run it. Builds and dev servers are usually the developer's job —
[`verification.md`](verification.md).

## Exit codes are the cheapest signal there is

`0` or non-zero answers "did it work" for ~0 tokens. Only pull the output when the answer is
non-zero, and then pull the *relevant slice*, not the stream.
