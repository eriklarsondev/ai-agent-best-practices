# Infrastructure code

**Open when:** writing or changing Terraform, Pulumi, CDK, k8s manifests, Helm charts,
Dockerfiles, or CI workflows.
**Skip if:** you're only reading them for context.

## Writing it is your job. Running it is not.

Infra code is code — author it like any other, following
[`consistency.md`](consistency.md) and [`file-organization.md`](file-organization.md).
Executing it belongs to the developer, **including the commands that look read-only**.

| Yours | Theirs |
| --- | --- |
| `.tf`, charts, manifests, Dockerfiles, CI config | `terraform init`, `plan`, `apply`, `destroy` |
| Module structure and variable design | `kubectl`, `helm`, `aws`/`gcloud`/`az` |
| Reading a plan they paste back | Anything that touches a real cluster or account |

**`plan` is not a safe read.** It needs live credentials, reads (and can lock) remote state,
and refreshes against real resources. `init` writes lock files and downloads providers. Ask
for the output; don't reach for the command.

## Writing it well

- **Follow the existing module layout.** Per module: `main.tf`, `variables.tf`,
  `outputs.tf`, `versions.tf`. Don't invent a structure next to one that exists.
- **Pin versions** — providers, modules, base images, action SHAs. An unpinned dependency is
  a change that happens without a diff.
- **No magic values.** A CIDR, port, or instance type that appears twice is a variable.
- **Comment the constraint, never the resource.** `# Pinned to 5.x — 6.0 renames the
  lifecycle block` earns its place; `# Create the S3 bucket` above `resource "aws_s3_bucket"`
  does not. See [`comments.md`](comments.md).
- **Name what a resource is for**, not what it is — `assets`, not `bucket_1`.

## Consulting on a plan they paste back

This is where you're most useful, and it costs nothing to run. Read for:

- **Replacements.** `must be replaced` / `forces replacement` on a stateful resource — a
  database, a volume, a disk — is data loss wearing an in-place-update costume. Say so
  loudly and first.
- **Unintended scope.** Resources in the diff that your change shouldn't have touched. Often
  drift: someone edited the console and the config never caught up.
- **Destroy counts.** `N to destroy` where you expected zero.
- **Silent recreation ordering.** A create-before-destroy that isn't set, on something that
  can't tolerate downtime.

Say plainly which lines you're reacting to. A plan is long; a reviewer needs the three that
matter.

## Stateful resources get flagged, always

When your change touches anything holding data — volumes, databases, disks, buckets with
retention — name it in the handoff even when you believe the change is safe. Getting it
wrong is unrecoverable, and the developer is the one who knows whether that data matters.

See also [`../boundaries.md`](../boundaries.md) for the data-destruction rules, and
[`handoff.md`](handoff.md) for what to hand over.
