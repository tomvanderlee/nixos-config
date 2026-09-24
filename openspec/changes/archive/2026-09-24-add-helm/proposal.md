## Why

Tom wants `helm` (the Kubernetes package manager CLI) available alongside the already-provisioned `kubectl`, so Helm charts can be installed/managed against whatever cluster `kubectl` is already pointed at.

## What Changes

- Add `pkgs.kubernetes-helm` to `modules/home/dev-tools.nix`'s CLI package list. Verified against the flake's pinned `nixos-unstable` nixpkgs input: Apache-2.0 licensed (free, no `lib/unfree-allowlist.nix` entry needed), broad platform support (`aarch64-darwin`, `x86_64-linux`, `aarch64-linux`, and more).
- No spec change needed — `developer-environment`'s existing "Developer CLI tools are provisioned via the shared home profile" requirement already covers adding another evidenced CLI tool to the list (the same reasoning previously used for `uv`, `bitwarden-cli`, `claude-code`), and its "Container and cloud tools are client-only" requirement already generally covers any Kubernetes/cloud CLI tool other than Docker — Helm needs no daemon or account of its own; it just talks to whatever cluster `kubectl` is already configured against.
- **BREAKING**: none — additive only.

## Capabilities

### New Capabilities
(none)

### Modified Capabilities
(none — covered by `developer-environment`'s existing requirements; no requirement text changes)

## Impact

- **Affected code**: `modules/home/dev-tools.nix` (add `pkgs.kubernetes-helm`).
- **Not affected**: `lib/unfree-allowlist.nix` (Helm is free-licensed), `modules/home/desktop-apps.nix`, `modules/nixos/common.nix`.
- **Dependencies**: nixpkgs' `kubernetes-helm` package, already present in the pinned `nixos-unstable` input; no new flake inputs.
- **Platforms**: provisioned cross-platform like the rest of `dev-tools.nix` — `homeConfigurations` (`tom@linux`, `tom@darwin`) and any NixOS host built via `lib/mkNixos.nix`.
- **Known limitation, out of scope**: no Kubernetes cluster or `kubeconfig` is installed or managed by this change, exactly like the existing `kubectl` provisioning — Helm is a client only.
