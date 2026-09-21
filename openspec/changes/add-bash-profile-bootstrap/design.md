## Context

See proposal.md - Why. This sits alongside `modules/home/dotfiles.nix` (`dotfiles-management`) without depending on it — this new behavior fires regardless of whether `home.dotfiles.repoUrl` is set. A real, repo-unmanaged `~/.bash_profile` (containing a plaintext Homebrew token) was found on the user's macOS machine during an earlier change's exploration and explicitly flagged out of scope there; the exists-check in this change is what makes it safe to run this feature on that same machine, and on any other machine that already has its own `.bash_profile`.

## Goals / Non-Goals

**Goals:**
- Create `~/.bash_profile` (sourcing `~/.bashrc`) exactly once, only when it doesn't already exist.
- Behave identically on every platform this flake targets, with no per-OS conditional.

**Non-Goals:**
- Managing the contents or ownership of `~/.bashrc` itself — that remains entirely owned by the external dotfiles repo, unchanged by this capability.
- Reconciling or updating a `~/.bash_profile` that already exists, however it got there.

## Decisions

**New capability (`shell-login-bootstrap`) instead of a `dotfiles-management` delta.** `dotfiles-management`'s own Purpose and first requirement are specifically about the opt-in `home.dotfiles.repoUrl` clone-and-stow feature ("SHALL only run when a repository URL has been explicitly configured"). This new behavior is unconditional and fires identically whether or not that URL is ever set, so folding it in would contradict that capability's own framing rather than extend it.

**A standalone `home.activation` script (`modules/home/bash-profile.nix`), not `programs.bash`.** `programs.bash` is deliberately not enabled anywhere in this repo (see the archived `add-developer-environment` design) because enabling it would make home-manager generate and own `~/.bashrc`, conflicting with the dotfiles-repo-owned `~/dotfiles/bash/.bashrc`. Reaching for `programs.bash.profileExtra` or similar would fight that existing setup, so this has to be a plain activation script writing a plain file directly, following the same `lib.hm.dag.entryAfter [ "writeBoundary" ]` idiom already used by `dotfiles.nix`.

**`[ -e ]`, not `[ -f ]`, for the exists-check.** `-e` also matches an existing symlink (e.g. a future dotfiles-repo-provided `.bash_profile` package), so a symlink is never clobbered either — only true absence triggers the write.

**`install -m 644` (GNU coreutils via `pkgs.coreutils`) instead of `cp` + `chmod`, and no temp-file-then-`mv` staging.** `install` sets content and permissions in one step, avoiding a GNU/BSD `install` behavior mismatch between Linux and macOS hosts. Temp-file staging was considered and rejected: this repo's only existing conditional-write precedent (`dotfiles.nix`'s `git clone`/`stow` calls) doesn't defend against partial writes either, activation scripts here run sequentially rather than concurrently, and the file is a few bytes — added complexity wasn't justified.

**No ordering dependency between this activation script and `dotfiles.nix`'s.** `dotfiles.nix`'s activation entry only exists at all when `cfg.repoUrl != ""` (`lib.mkIf`-gated). A hard `entryAfter [ "dotfiles" ]` reference would leave the DAG edge dangling whenever the dotfiles feature is disabled — fragile for no benefit. Both possible race outcomes are already safe without any explicit ordering: if `dotfiles`'s stow step runs first and links a `.bash_profile` package, the `[ -e ]` check sees it and skips (the dotfiles-repo-owned file wins, consistent with the existing `.bashrc`/`.gitconfig` precedent); if this block runs first and creates the plain bootstrap file, and the dotfiles repo also ships a `.bash_profile` package, `stow` hits an occupied target and — per `dotfiles-management`'s existing "a conflicting package does not block the others" requirement — skips just that one package with a visible warning, without aborting. Accepted explicitly rather than engineered around.

## Risks / Trade-offs

- **A pre-existing, unmanaged `~/.bash_profile` (e.g. the one with a plaintext Homebrew token on the user's Mac) is left completely untouched, including if it's stale or wrong** → This is the explicit intent, not an oversight: the exists-check guard is a hard requirement precisely so this feature never touches a file it doesn't own.
- **No local way to verify activation behavior since Nix isn't installed on this development machine** → Same constraint as every prior change in this repo; `nix flake check` and a real `home-manager switch` remain the acceptance gate.
