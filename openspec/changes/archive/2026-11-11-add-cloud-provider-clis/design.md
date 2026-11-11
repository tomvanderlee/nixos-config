# Design

## Context

`modules/home/dev-tools.nix` holds one flat `with pkgs;` list of client CLIs, already including `kubectl`, `kubernetes-helm` and `awscli2`. See proposal.md for motivation. The flake's home/NixOS outputs are x86_64-linux, aarch64-linux (hosts) and aarch64-darwin (`tom@darwin`).

## Goals / Non-Goals

**Goals:**
- `aws`, `az` and `gcloud` on `PATH` on every output in this flake, with no per-platform conditionals.

**Non-Goals:**
- Declarative cloud configuration or secrets handling.

## Decisions

- **Plain package entries, no `availableOn` filter.** `azure-cli` and `google-cloud-sdk` lack x86_64-darwin in nixpkgs, but this flake has no x86_64-darwin output, so a filter would be dead code. If such an output is added, wrap these entries in `lib.meta.availableOn` as `modules/home/desktop-apps.nix` does. Alternative considered: filter now for future-proofing; rejected as speculative.
- **Same file, same list.** The three CLIs sit beside `awscli2` in `dev-tools.nix` rather than a new `cloud.nix` module; one line each does not justify a module.
- **Stock `google-cloud-sdk`, no extra components.** `withExtraComponents` (e.g. `gke-gcloud-auth-plugin`) is deferred until a concrete need; the stock package is cheap to reason about and is a one-line change later.
- **Port forwarding per provider.** GCP: `google-cloud-sql-proxy` (Cloud SQL Auth Proxy, authenticates with gcloud/ADC credentials and exposes the instance on localhost). AWS: `ssm-session-manager-plugin`, needed by `aws ssm start-session --document-name AWS-StartPortForwardingSessionToRemoteHost` to tunnel to an RDS endpoint through an SSM-managed instance; AWS has no first-party standalone RDS proxy for developer machines. Azure: no database proxy exists, so use `azure-cli.withExtensions [ azure-cli.extensions.bastion ]` for `az network bastion tunnel`. Alternative considered for Azure: skip it; rejected because the user asked for equivalents where any exist, and Bastion tunnelling is the closest. Extensions are baked in via `withExtensions` because `az extension add` cannot write to the read-only store.
- **No unfree allowlist entry.** All licenses are free per nixpkgs metadata, so `lib/unfree-allowlist.nix` is untouched.

## Risks / Trade-offs

- [`az network bastion tunnel` requires a Standard-SKU Azure Bastion with tunnelling enabled, and `aws ssm start-session` requires an SSM-managed jump host] → These are remote-side prerequisites, out of scope; the tools are inert without them.
- [Closure size: `google-cloud-sdk` and `azure-cli` are each several hundred MB] → Accepted; they are on-demand tools Tom already pulls through `nix shell`. Rollback is removing the entries.
- [nixpkgs package lags upstream releases, and `gcloud components install` does not work on a read-only store install] → Use `withExtraComponents` or `nix shell` if a component is needed.
