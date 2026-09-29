## Why

Tom wants `nh` (the Nix CLI helper from nix-community — nicer `nixos-rebuild`/`home-manager switch` output, generation diffing, and store cleanup) available in the shared profile, the same way `helm` and other CLI tools have been added incrementally to `modules/home/dev-tools.nix`.

## What Changes

- Enable `programs.nh` (home-manager's own module for this tool, at `modules/programs/nh.nix` in the pinned `home-manager` input) from `modules/home/dev-tools.nix`, with just `enable = true`. This provisions the `nh` package on `PATH` cross-platform, exactly like every other entry already in that file.
- Deliberately leave `programs.nh.flake` / `osFlake` / `homeFlake` unset, and `programs.nh.clean.enable` off:
  - This repo's own `dotfiles-management` capability already deliberately removed home-manager's `programs.bash` management because the user's personal dotfiles repo is the sole owner of `~/.bashrc` once stowed. Home-manager's `sessionVariables` (which is how `programs.nh.flake`/`osFlake`/`homeFlake` reach the shell) are only guaranteed to reach an interactive shell if something sources `hm-session-vars.sh` from the shell's rc file — and that rc file is owned by the dotfiles repo, not this one, so this repo cannot make that guarantee. Setting a flake path here would silently do nothing for Tom's actual shell.
  - There's also no established convention in this repo for where the flake is checked out on a given machine (`hosts/`/`scripts/bootstrap-host.sh` never reference a fixed checkout path), so hardcoding one would be a guess.
  - `programs.nh.clean.enable` would add an automatic, periodic `nh clean user` timer — a new behavior beyond "make the `nh` binary available," and out of scope for this change (Tom can enable it later himself, or add it to his own dotfiles/systemd units, if he wants it).
- **BREAKING**: none — additive only.

## Capabilities

### New Capabilities
(none)

### Modified Capabilities
(none — covered by `developer-environment`'s existing "Developer CLI tools are provisioned via the shared home profile" requirement, the same reasoning already used for `uv`, `bitwarden-cli`, `claude-code`, and `kubernetes-helm`. No requirement text changes.)

## Impact

- **Affected code**: `modules/home/dev-tools.nix` (add `programs.nh.enable = true;`).
- **Not affected**: `lib/unfree-allowlist.nix` (`nh` is EUPL-1.2 licensed — free, not flagged unfree in nixpkgs), `modules/nixos/common.nix`, `modules/home/dotfiles.nix`.
- **Dependencies**: nixpkgs' `nh` package (verified present and unfree-free in the flake's pinned `nixos-unstable` input, version 4.4.2) and home-manager's `programs.nh` module (verified present at `modules/programs/nh.nix` in the flake's pinned `home-manager` input). No new flake inputs.
- **Platforms**: provisioned cross-platform like the rest of `dev-tools.nix` — verified evaluating cleanly for `x86_64-linux`, `aarch64-linux`, `aarch64-darwin`, and `x86_64-darwin`, so it's available on both `homeConfigurations` (`tom@linux`, `tom@darwin`) and any NixOS host built via `lib/mkNixos.nix`.
- **Known limitation, out of scope**: no `NH_FLAKE`/`NH_OS_FLAKE`/`NH_HOME_FLAKE` environment variable is set, and no periodic cleanup timer is enabled — see "What Changes" above for why. Tom runs `nh os switch -- --flake <path>` / `nh home switch -- --flake <path>` explicitly, or sets the env var himself in his own dotfiles, until/unless a follow-up change decides otherwise.
