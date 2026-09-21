## Why

NixOS (and most other Linux distros) don't ship a `~/.bash_profile` that sources `~/.bashrc`, so login shells never pick up the user's bash config — only interactive non-login shells do. This repo made bash the primary managed shell in an earlier change (`add-developer-environment`), and the real `.bashrc` lives in the user's external dotfiles repo (`~/dotfiles/bash/.bashrc`, stowed to `~/.bashrc` by `modules/home/dotfiles.nix`), so this gap is real on any freshly provisioned machine.

## What Changes

- Add a new home-manager activation script that creates `~/.bash_profile` (sourcing `~/.bashrc` if present) only when `~/.bash_profile` does not already exist. An existing `~/.bash_profile`, in any form (regular file or symlink), is never modified.
- Applies unconditionally on every platform this flake targets (Linux and macOS) — not gated by `home.dotfiles.repoUrl` — since the exists-check itself is what keeps it safe everywhere, including on a machine with an existing, repo-unmanaged `~/.bash_profile`.

## Capabilities

### New Capabilities
- `shell-login-bootstrap`: ensures a login shell sources `~/.bashrc` via `~/.bash_profile`, creating that file only when it doesn't already exist, on every platform this flake targets.

### Modified Capabilities
(none — `dotfiles-management`'s existing "a conflicting package does not block the others" requirement already covers the rare case where a dotfiles-repo-provided `.bash_profile` package races against this file; no requirement of that capability changes)

## Impact

- Affected code: a new `modules/home/` module, registered in `modules/home/default.nix`'s imports; `README.md`'s documentation of the home-manager module layout and shell setup.
- Applies to every `homeConfigurations`/`nixosConfigurations` output built from the shared home profile (both `tom@linux` and `tom@darwin`, plus any future NixOS host).
- No change to `dotfiles.nix` or its behavior.
