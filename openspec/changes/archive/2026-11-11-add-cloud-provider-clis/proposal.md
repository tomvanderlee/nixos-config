# Proposal

## Why

The shared profile already carries `awscli2`, but Tom also works against Azure and Google Cloud, and has to reach for `nix shell nixpkgs#azure-cli` or `nixpkgs#google-cloud-sdk` each time. Provisioning the command-line tools for all three major cloud providers makes them uniformly available wherever the profile is activated.

## What Changes

- Add `azure-cli` (provides `az`) and `google-cloud-sdk` (provides `gcloud`, `gsutil`, `bq`) to the CLI packages in `modules/home/dev-tools.nix`, next to the existing `awscli2` (provides `aws`).
- Add the database port-forwarding helpers for each provider: `google-cloud-sql-proxy` (`cloud-sql-proxy`, the Cloud SQL Auth Proxy), `ssm-session-manager-plugin` (`session-manager-plugin`, which lets `aws ssm start-session` forward a local port to an RDS endpoint), and the Azure Bastion extension for `azure-cli` (`az network bastion tunnel`). Azure has no dedicated database proxy; Bastion tunnelling is its closest equivalent.
- Extend the `developer-environment` requirement "Container and cloud tools are client-only" so its exceptions list covers the new tools instead of naming only `kubectl` and `awscli2`.
- Add one `developer-environment` requirement stating that the AWS, Azure and Google Cloud CLIs are provisioned.
- **BREAKING**: none.

## Capabilities

### New Capabilities
(none)

### Modified Capabilities
- `developer-environment`: adds a requirement that the three cloud-provider CLIs and their local port-forwarding helpers are provisioned; updates the client-only requirement to name them.

## Impact

- **Affected code**: `modules/home/dev-tools.nix`.
- **Also affected**: `flake.lock` (nixpkgs 2026-11-01 → 2026-11-07, home-manager 2026-11-04 → 2026-11-10). The previously pinned nixpkgs marked `python3.14-fabric` broken, which made `azure-cli` fail to evaluate; the newer revision fixes it.
- **Not affected**: `lib/unfree-allowlist.nix` (verified: `azure-cli` and its bastion extension are MIT, `awscli2`, `ssm-session-manager-plugin` and `google-cloud-sql-proxy` are Apache-2.0, `google-cloud-sdk` carries nixpkgs' "unspecified free software" license; none is marked unfree), `modules/nixos/*`, `flake.nix`, `hosts/*`.
- **Platforms (verified with `nix eval nixpkgs#<pkg>.meta.platforms`)**: all of these packages build on x86_64-linux, aarch64-linux and aarch64-darwin, which covers every home and NixOS output in this flake. x86_64-darwin is absent from nixpkgs for `azure-cli` and `google-cloud-sdk`, but the flake has no x86_64-darwin output, so no availability filter is needed.
- **Assumptions**: "sdk/cli tools" is read as the provider command-line tools. `google-cloud-sdk` is the nixpkgs package that ships `gcloud`; there is no separate Azure or AWS "SDK" package for the CLI. Language SDKs (boto3, azure-sdk, google-cloud-* libraries) are per-project dependencies and belong in each project's `uv`/npm/cargo manifest, not the shared profile.

## Non-goals

- Language-specific SDK libraries (boto3, Azure SDK for Python/JS, Google Cloud client libraries).
- Provisioning the remote side of any tunnel (Cloud SQL instances, RDS, a bastion host or an EC2/SSM-managed jump host); the tools only connect to what already exists.
- Authentication or account configuration (`aws configure`, `az login`, `gcloud auth login`), credentials, profiles or default regions/projects.
- `gcloud` components beyond what the nixpkgs package ships (e.g. `google-cloud-sdk.withExtraComponents`, GKE auth plugin); can be a follow-up if needed.
- Infrastructure-as-code tools (Terraform, Pulumi, OpenTofu).
