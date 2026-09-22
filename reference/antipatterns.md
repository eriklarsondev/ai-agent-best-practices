# Antipatterns

**Open when:** you suspect the move you're about to make is expensive.
**Skip if:** you already know the cheap form.

Deltas are order of magnitude, not measurements.

| ✗ | ✓ | Rough delta |
| --- | --- | --- |
| Read `package-lock.json` / `yarn.lock` / `Cargo.lock` | `jq -r '.dependencies \| keys[]'`, or `rg -n '"name"' -m1` | 200k → 200 |
| Read a file to find one symbol | `rg -n 'symbol' path/` | 6k → 50 |
| Re-read a file to confirm your edit applied | nothing; the tool already errors on failure | 6k → 0 |
| Run a test suite yourself | write the test, hand over the exact command | 15k → 40 |
| `find . -name '*.py'` | `rg --files -g '*.py'` (respects ignore files) | 40k → 500 |
| `ls -R` or `tree` at repo root | `rg --files \| head -40`, or glob the dir you care about | 100k+ → 300 |
| `git diff` on a branch that touched a lockfile | `git --no-pager diff -- . ':(exclude)*lock*'` | 200k → 3k |
| `git log` (pager, full bodies) | `git --no-pager log --oneline -10` | 20k → 200 |
| Read the whole 3000-line file to orient | grep the symbol lines for an outline, read one region | 40k → 1k |
| Rewrite a file to change three lines | targeted replacement of a unique anchor | 12k → 200 |
| Reformat untouched lines while editing | leave them; a 4-line diff reviews in seconds | 8k → 200 |
| 30 sequential reads to answer "where is X used" | one subagent, deliverable = `file:line` list | 80k → 3k |
| Spawn a subagent for a single known lookup | just read it; spawn overhead > the read | 4k → 300 |
| Delegate a search *and* run it yourself | pick one | 2× → 1× |
| Ask a clarifying question the repo answers | grep for it | one full turn → 100 |
| Re-explain a decision the user already made | say nothing | 500 → 0 |
| Narrate each tool call as you go | act, then report the outcome once | 2k → 100 |
| Paste the final diff into your response | `file:line` plus a one-line summary | 4k → 40 |
| Write a plan longer than the change | make the change | — |
| Hold a long build's stream in context | `> /tmp/build.log 2>&1; tail -30 /tmp/build.log` | 30k → 400 |
| Read a 5MB CSV/JSON fixture | `head -3` for shape, `jq`/`awk` for the values | 1M → 200 |
| Dump an image/SVG/base64 asset | check the path exists; don't open it | huge → 0 |

## The meta-antipattern

Reading to feel thorough. Every read should be answering a question you could state out loud
first. If you can't say what the read will decide, don't make it.
