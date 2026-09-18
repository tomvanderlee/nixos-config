## Context

See proposal.md - Why. This builds on the shared `modules/home` layer from `add-nix-flake-bootstrap`. The target dotfiles repo (`~/dotfiles`) already exists on the development machine, is genuinely GNU-Stow-structured (confirmed by reading it directly: top-level directories are packages mirroring `$HOME`, its own README says "Run `stow [dir]`"), has real git history across three remotes, and includes a submodule (`vim/.vim/vim-plug`). Nix is still not installed on this machine, so nothing here can be locally evaluated or executed — same constraint as the two prior changes.

## Goals / Non-Goals

**Goals:**
- Make the clone-and-stow step part of ordinary `home-manager switch` activation, requiring no separate manual command.
- Never touch an already-existing dotfiles checkout (idempotent and non-destructive by construction).
- Keep nix-config decoupled from the dotfiles repo's specific package list — no hardcoded package names to keep in sync.
- Leave the actual repo URL for the user to fill in, per their explicit request.

**Non-Goals:**
- Deciding *which* of the dotfiles packages are relevant per platform (e.g. `herbstluftwm`/`xorg` are X11-only). No filtering is implemented; harmless unused symlinks are accepted rather than hardcoding platform-specific package knowledge into nix-config.
- Managing secrets or anything requiring authentication beyond a plain `git clone` of a public URL (the user described the URL as public).
- Migrating the *content* of `~/dotfiles/git/.gitconfig` itself — only which system (home-manager vs. the dotfiles repo) owns `~/.gitconfig` is in scope.

## Decisions

**Use a home-manager `home.activation` script, not a systemd/launchd service or a separate CLI command.** This is the standard home-manager idiom for "run this during activation" needs (already established precedent in this repo's design philosophy of using first-class module-system features over bespoke tooling). It runs as part of `home-manager switch`, requiring no additional invocation, and integrates with home-manager's dry-run convention (`$DRY_RUN_CMD`).

**Package enumeration is generic (loop over top-level non-hidden directories), not a hardcoded list.** The alternative — listing `bash`, `git`, `neovim`, `tmux`, etc. explicitly in nix-config — was rejected because it re-couples nix-config to the dotfiles repo's exact contents, meaning every new package added there would require a corresponding nix-config change. A generic directory-enumeration rule stays correct as the dotfiles repo evolves and naturally excludes the observed stray entries (`README.md`, `nvim.log`, `.DS_Store`, `.git*`, `.claude/`) without needing to name them.

**`programs.git.enable` is removed rather than kept alongside the stowed `git/.gitconfig`.** Home-manager's git module always writes `~/.gitconfig` once enabled — there's no way to keep the module "enabled" while suppressing that file, so the two approaches are fundamentally exclusive for the same path. Given the user chose to let the dotfiles repo own git config, the home-manager side is fully removed rather than left half-configured. `pkgs.git` moves to `cli-tools.nix` so the binary itself doesn't disappear.

**Per-package `stow` invocations, not one invocation for all packages.** GNU Stow's default behavior aborts the whole operation if any named package conflicts. Invoking it once per package, with a non-fatal warning on failure, means one conflicting package (or a not-yet-relevant one on this platform) never blocks the rest from being linked.

**`homeConfigurations."tom@darwin"` is added now, not deferred.** Unlike the nix-darwin deferral in earlier changes (which was about an untestable *system*-level integration), this is a lightweight, already-proven pattern (the same `mkHome` helper, just a different `system` string) — and without it, this feature has no way to actually be exercised on the machine it matters most for.

## Risks / Trade-offs

- **Removing `modules/home/git.nix` is a breaking change for git identity** → Mitigation: called out explicitly in the proposal's Impact section; `~/dotfiles/git/.gitconfig` already exists with real content on this machine, so the practical gap is only during the window before `home.dotfiles.repoUrl` is filled in and first activated.
- **No local way to verify the activation script's actual clone/stow behavior, since Nix isn't installed here** → Mitigation: same as prior changes — careful manual construction and review now; real verification deferred until Nix is available. This is the actual acceptance gate, not any individual task checkbox.
- **Unused symlinks for platform-irrelevant packages (`herbstluftwm`, `xorg`) will exist on this Mac** → Mitigation: accepted per the Non-Goals above; an inert dangling-but-harmless symlink is a smaller cost than hardcoding package names.
- **A conflict warning could go unnoticed since it's non-fatal** → Mitigation: the warning is written to stderr on every activation until resolved (not silenced after the first occurrence), keeping it visible without being disruptive.
