## Why

Tom's dotfiles repo lives on GitHub (`github.com/tomvanderlee/dotfiles`) but is self-hosted on Forgejo for day-to-day work. A fresh machine has no SSH key and can't reach the LAN-only Forgejo, but can clone the public GitHub copy. It should bootstrap from GitHub and then be wired so Forgejo is the branch's upstream (Forgejo mirrors pushes to GitHub).

## What Changes

- The initial dotfiles clone is made from GitHub, with the clone source recorded as a git remote named `github`.
- After that first clone, a second remote named `origin` is added pointing at the Forgejo SSH URL `ssh+git://git@forgejo.lan.tomvanderlee.com:2222/tom/dotfiles.git`, and the checked-out branch is configured to track `origin` (Forgejo), so a bare `git push`/`git pull` targets Forgejo. Forgejo push-mirrors to GitHub, so GitHub stays current without being pushed to directly.
- New optional module option `home.dotfiles.originUrl` (default empty) in `modules/home/dotfiles.nix`. When empty, behavior is unchanged (plain clone, remote named `origin`).
- `users/tom.nix`: `home.dotfiles.repoUrl` changes from `https://git.tomvanderlee.com/dotfiles` to `https://github.com/tomvanderlee/dotfiles.git`, and `home.dotfiles.originUrl` is set to the Forgejo URL above.
- Remotes are only configured as part of the first clone. An existing `~/dotfiles` checkout is still never touched, including its remotes.
- **BREAKING**: none for machines that already have `~/dotfiles`. On a fresh clone the fetch remote is now named `github` rather than `origin`.

## Capabilities

### New Capabilities
(none)

### Modified Capabilities
- `dotfiles-management`: the "Checkout missing" behavior gains a requirement to optionally configure a separate push-target `origin` remote after the initial clone.

## Impact

- **Affected code**: `modules/home/dotfiles.nix` (new option, clone command with `-o github`, `git remote add origin`), `users/tom.nix` (two option values).
- **Not affected**: `lib/unfree-allowlist.nix`, `modules/nixos/common.nix`, stow/exclude logic.
- **Dependencies**: none new. Uses `git clone --origin` and `git remote add`, both in the already-provisioned `pkgs.git`.
- **Assumptions**: `github` is the remote name for the clone source and `origin` is Forgejo. The branch's upstream is set via config (`branch.<name>.remote`/`merge`) without fetching, because Forgejo is unreachable on a new machine; `origin/<branch>` refs appear after the first `git fetch origin` once SSH is set up.
- **Non-goals**: migrating existing checkouts, configuring Forgejo SSH keys or host-key trust, and mirroring between GitHub and Forgejo.
