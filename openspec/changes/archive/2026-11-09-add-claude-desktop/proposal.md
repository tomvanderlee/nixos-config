# Proposal

## Why

Anthropic ships a beta Claude Desktop app for Linux, but only as a `.deb` and an apt repository for Debian/Ubuntu (https://code.claude.com/docs/en/desktop-linux). nixpkgs has no `claude-desktop` package (`nix search nixpkgs claude-desktop` returns nothing), so it cannot be installed on this flake's NixOS hosts today. Tom wants it provisioned declaratively like the other desktop apps.

## What Changes

- Add a local package `pkgs/claude-desktop.nix` that repackages Anthropic's official `.deb` (fetched from `https://downloads.claude.ai/claude-desktop/apt/stable/pool/...`, pinned by version and SHA-256 for `amd64` and `arm64`) into a Nix store path, patched to run on NixOS, with a `.desktop` entry and icon.
- Add `claude-desktop` to the shared home profile in `modules/home/desktop-apps.nix`, filtered to Linux and to platforms the package supports (via the existing `lib.meta.availableOn` mechanism), so macOS and unsupported systems drop it silently.
- Add `claude-desktop` to `lib/unfree-allowlist.nix` (the app is proprietary).
- Document how to bump the pinned version in `README.md`.
- **BREAKING**: none.

## Capabilities

### New Capabilities
(none)

### Modified Capabilities
- `desktop-applications`: Claude Desktop joins the provisioned GUI applications, restricted to Linux systems with a supported build.

## Impact

- **Affected code**: new `pkgs/claude-desktop.nix`; `modules/home/desktop-apps.nix`; `lib/unfree-allowlist.nix`; `README.md`.
- **Not affected**: `flake.nix`, `modules/nixos/*`, `hosts/*`, standalone/NixOS wiring in `lib/mk*.nix`.
- **Verified facts** (from the official docs page and the apt `Packages` index): publisher is Anthropic PBC; formats are `.deb` only; architectures `amd64` and `arm64`; latest version at proposal time is `4.23118.0` (amd64 SHA-256 `1ad996e8caab05c9b374646051c40cb6bb9d84f371756f15b8d3728897515a97`, arm64 SHA-256 `b4c04e08338b321f5c02543ab6be819cbb9f38ef051a3e7d8ffdc5b4d5248ea4`); the app does not self-update on Linux; no license text is published on the docs page, so it is treated as unfree.
- **Assumptions**: GNOME (already enabled on all hosts) provides the portal and keyring the app depends on. The package's Cowork feature (QEMU/KVM VM) is optional and not provisioned by this change.

## Non-goals

- Cowork support (qemu, OVMF, virtiofsd, `kvm` group, `vhost_vsock`); Computer Use and Dictation are not yet available upstream anyway.
- macOS support (Anthropic distributes a different build there; this change is Linux-only).
- Automated version bumping (an update script or CI); bumps are manual and documented.
- Using a community repackaging flake instead of the official `.deb`.
