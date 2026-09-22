# Config and environment changes

**Open when:** adding, renaming, or removing a config value or environment variable.
**Skip if:** you're only reading config.

## The failure this prevents

Code reads `NEW_VAR`. It works on the developer's machine, because their shell already has
it. It boots in CI with an empty string, or dies in staging at 3am with a `NoneType` error
four call frames from anything meaningful.

A config key lives in **five to eight places**, and the code that reads it is only one. Miss
one and the failure surfaces somewhere that isn't your change.

## The trick: let an existing var write your checklist

Don't work from memory. Pick a variable that already exists and grep it — everywhere it
appears is everywhere yours needs to go:

```sh
rg -n 'DATABASE_URL' -g '!*.lock' -g '!node_modules'
```

That's the whole practice. One command, exact answer, zero guessing, and it adapts to
whatever the repo actually does.

## What it usually turns up

| Place | Why it matters |
| --- | --- |
| The reader itself | Where you started |
| `.env.example` / `.env.sample` | The contract with every future developer. If it isn't here, it doesn't exist |
| Config validation schema | Many repos validate at boot — an unlisted var is silently `None` |
| CI config | Workflow `env:` blocks and repo secrets |
| Deploy config | `docker-compose.yml`, k8s manifests, ConfigMaps/Secrets, Terraform, Helm values |
| Root README setup section | The step someone follows on day one — [`editing.md`](editing.md) |
| Test setup | Fixtures, `conftest`, test env files |

## Rules

- **Required means fail loudly at boot.** A missing required var should stop startup with a
  message naming the variable — not return `None` and surface as a mystery later.
- **Never put a real secret in `.env.example`.** Name and shape only:
  `DATABASE_URL=postgres://user:pass@localhost:5432/dbname`. See
  [`untrusted-content.md`](untrusted-content.md).
- **Renaming is expand/contract**, same as a schema change: read both for one deploy, then
  drop the old. Don't rename in one step — [`migrations.md`](migrations.md).
- **Removing** means grepping the same list and deleting it everywhere, including the deploy
  config the developer may have forgotten they set.
- **Type it at the edge.** Env vars are strings. Parse and validate at the boundary — `"false"`
  is truthy in most languages, and that bug is very hard to see.

## Flag it in the handoff

Every new variable gets named with whether it's required and what happens without it — this
is config the developer must set *before* your change works, so it belongs at the top of the
handoff, not buried in a file list:

> Adds `STRIPE_WEBHOOK_SECRET` (required — the webhook route returns 500 without it). Added
> to `.env.example`, the compose file, and the CI workflow; **your local `.env` needs it too.**
