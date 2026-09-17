## Context

See proposal.md - Why. This builds on the shared `modules/home` and `modules/nixos/common.nix` layers from `add-nix-flake-bootstrap`, and follows the file-ownership precedent set by `add-dotfiles-stow-bootstrap` (home-manager's `programs.git` was removed there because `~/dotfiles/git/.gitconfig` already owns `~/.gitconfig`; the same conflict now applies to `~/.bashrc` and the prompt config). Package selection is grounded in a direct exploration of this machine (Homebrew, PATH, shell configs) and `~/dotfiles`, followed by a Q&A with the user. Nix is still not installed on this machine, so nothing here can be locally evaluated or run.

## Goals / Non-Goals

**Goals:**
- Bring the flake's provisioned packages in line with actually-evidenced usage on the user's machine, not a generic/assumed list.
- Keep file-ownership conflicts resolved the same way as the established precedent: dotfiles wins for any file it already manages.
- Enable a sensible, secure-by-default SSH baseline for any future NixOS host, without requiring a live host to exist yet.

**Non-Goals:**
- Managing per-project language runtime versions (node/python/rust) via Nix — pyenv/nvm/rustup already own that; per-project pinned toolchains belong in project-level flake devShells later, a separate future change.
- Replacing Mason's role in managing neovim's LSP servers/formatters/debuggers.
- Making Docker Desktop/OrbStack or any cloud account itself Nix-managed — only client/CLI tools are in scope.
- Fixing the plaintext `HOMEBREW_GITHUB_API_TOKEN` found in `~/.bash_profile` during exploration — flagged to the user, not addressed here since it's outside any file this repo manages.

## Decisions

**`programs.bash` is not enabled, even though bash is now the primary shell.** Enabling it would make home-manager generate and own `~/.bashrc`, directly conflicting with `~/dotfiles/bash/.bashrc` (a real Stow package containing the user's actual PATH/alias/pyenv/nvm/rustup setup). Consistent with the `~/.gitconfig` precedent, the dotfiles-owned file wins. Consequence: `programs.starship`/`programs.direnv`'s automatic shell-hook injection has nowhere to write into for bash even if those modules were kept enabled — moot here since both are removed outright per user instruction, but worth recording as the underlying reason those integrations wouldn't have worked cleanly anyway.

**`programs.starship` and `programs.direnv` are removed outright, not left as-is.** This was an explicit correction from the user during plan review (the first draft kept them). `liquidprompt` replaces starship as the package Nix provisions, with its actual configuration and shell activation fully owned by `~/dotfiles/liquidprompt/` — matching the same "package via Nix, config via dotfiles" split already established for git. direnv was reconsidered once (the user asked why it mattered — per-project flake devShell auto-activation) and still explicitly removed after that explanation, so this is a confirmed, informed decision, not an overlooked default.

**`yq-go` over `yq`.** nixpkgs carries both the older Python-based `yq` (a thin `jq` wrapper for YAML) and `yq-go` (mikefarah's Go-based standalone tool) under different attribute names. The Go version is what's conventionally meant by "yq" in modern Kubernetes/Terraform-adjacent workflows, which matches this user's evidenced tooling (kubectl, terraform). Picking the wrong one would be a functionally different CLI with different syntax, not just a version difference.

**`terraform`'s nixpkgs availability is flagged as a risk, not silently assumed.** HashiCorp's BSL license change means recent nixpkgs may require `nixpkgs.config.allowUnfree = true` for `terraform`, or may have removed it in favor of `opentofu`. This can't be verified without Nix installed locally; the task list treats it as an implementation-time check rather than asserting it will just work.

**`services.openssh.settings.PasswordAuthentication = false` and `PermitRootLogin = "no"`.** The user already has SSH keys configured (4 hosts in `~/.ssh/config`), so key-only auth costs nothing and is the standard secure default. `networking.firewall.allowedTCPPorts = [ 22 ]` is the only firewall change that actually matters (NixOS's firewall is already enabled by default) — kept alongside an explicit `enable = true` purely as visible documentation of intent.

**A new `modules/home/dev-tools.nix` file, separate from the existing `cli-tools.nix`.** Keeps this change's additions traceable to this specific capability, matching the repo's established one-concern-per-file module convention rather than growing the original baseline file indefinitely.

## Risks / Trade-offs

- **No Nix-managed per-project environment activation after removing direnv** → Mitigation: this was a deliberate, explained trade-off the user confirmed twice; pyenv/nvm/rustup remain fully functional as the existing mechanism.
- **Prompt/shell integration (liquidprompt) depends entirely on the external `~/dotfiles` repo being present and correctly stowed** → Mitigation: this is exactly what the `add-dotfiles-stow-bootstrap` change already automates; no new risk introduced here, just a new consumer of that existing mechanism.
- **`terraform` may fail to evaluate without an unfree-package allowance** → Mitigation: flagged explicitly as a task-level check; if it fails, the fallback is either adding `nixpkgs.config.allowUnfree = true` or substituting `opentofu`, decided when Nix is actually available to test.
- **No local way to verify any of this evaluates or builds, since Nix isn't installed here** → Mitigation: same as every prior change — careful manual construction and package-name review now; `nix flake check` deferred until Nix is available. This remains the real acceptance gate across all changes in this repo, not any individual task checkbox.
