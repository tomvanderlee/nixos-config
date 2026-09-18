## Why

The flake currently ships a minimal, generic package set. The user is a software developer whose actual machine already relies on a specific set of CLI tools (git-adjacent, container/cloud tooling) and a specific shell/prompt setup that the flake doesn't reflect yet, and has no common system services (like sshd) enabled for future NixOS hosts. This change brings the flake's declared packages/services in line with real, evidenced usage.

## What Changes

- Add `modules/home/dev-tools.nix`: `gh`, `tmux`, `htop`, `yq-go`, `tree-sitter`, `docker`, `docker-compose`, `kubectl`, `awscli2`, `terraform` — user-level CLI/client tools, added to `modules/home/default.nix`'s imports. Container/cloud entries are client-only; the actual runtime (OrbStack/Docker Desktop) and cloud infrastructure stay outside Nix's control.
- **BREAKING**: `modules/home/shell.nix` drops `programs.zsh` (bash is now the primary managed shell), drops `programs.starship` (replaced by `liquidprompt`, already Stow-managed via the user's dotfiles), and drops `programs.direnv`/`nix-direnv` entirely — a real removal of a feature present since the first change in this repo, per explicit user instruction rather than an addition being skipped.
- `modules/home/shell.nix` adds `pkgs.liquidprompt` as a package (its config/activation stays fully owned by the user's dotfiles repo, matching the precedent already set for git and bash).
- `modules/nixos/common.nix`: `users.users.tom.shell` changes from `pkgs.zsh` to `pkgs.bash`; the `programs.zsh.enable = true` line is removed; `services.openssh` is enabled with `PasswordAuthentication = false` and `PermitRootLogin = "no"`; `networking.firewall` is set with port 22 explicitly allowed.
- Update `README.md` to document the new packages, the CLI-only caveat for docker/kubectl/awscli/terraform, the bash-primary shell switch, and that liquidprompt's config is dotfiles-owned.

## Capabilities

### New Capabilities
- `developer-environment`: the flake provisions a developer's most-used CLI/client tooling via home-manager and enables common baseline system services (starting with sshd + a firewall allowance) via the shared NixOS module.

### Modified Capabilities
(none — this doesn't change any requirement from `nix-flake-bootstrap` or `dotfiles-management`; the shell/prompt/direnv changes are implementation details of the new capability's package/service set, not a change to what those other capabilities promise)

## Impact

- Affected code: `modules/home/dev-tools.nix` (new), `modules/home/shell.nix`, `modules/home/default.nix`, `modules/nixos/common.nix`, `README.md`.
- No live NixOS host exists yet, so the `services.openssh`/`networking.firewall` additions only take effect once a real host is scaffolded — same situation as every prior NixOS-side change in this repo.
- Nix is still not installed on this development machine, so package-name correctness (`yq-go`, `awscli2`, `tree-sitter`, `terraform`'s licensing/availability) can only be verified by manual review here, not by actually building — same constraint as every prior change.
- User-visible: anyone relying on the previously-configured `zsh`/`starship`/`direnv` home-manager setup loses it entirely once this change lands; bash + liquidprompt (dotfiles-owned) replaces it, and there is no Nix-managed per-project environment activation mechanism (direnv) after this change.
- Not in scope: a plaintext `HOMEBREW_GITHUB_API_TOKEN` was found in `~/.bash_profile` (not Nix-managed) during exploration — flagged to the user separately, not addressed by this change.
