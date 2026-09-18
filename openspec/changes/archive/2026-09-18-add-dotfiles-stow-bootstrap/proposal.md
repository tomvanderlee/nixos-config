## Why

The user maintains a separate `~/dotfiles` repo (already Stow-structured: top-level directories mirror `$HOME`, e.g. `git/.gitconfig` → `~/.gitconfig`) that today has to be cloned and stowed by hand on every machine. This change makes that automatic as part of home-manager activation, so a fresh machine ends up with the same personal dotfiles in place without a manual step.

## What Changes

- Add `modules/home/dotfiles.nix`: a home-manager module exposing `home.dotfiles.repoUrl` (a plain string option, empty by default) and a `home.activation.dotfiles` script that, when a URL is set, clones the repo to `~/dotfiles` (only if not already present — never reclones over an existing checkout) and stows every top-level, non-hidden directory into `$HOME`, independently per package so one conflicting package doesn't block the rest.
- **BREAKING**: remove home-manager's own git configuration management — delete `modules/home/git.nix` and its import, and drop the `programs.git.userName`/`userEmail` block from `users/tom.nix`. `~/dotfiles/git/.gitconfig` becomes the sole source of git config once stowed, since home-manager's `programs.git.enable` and a stowed `~/.gitconfig` cannot coexist (home-manager always writes that file once the module is enabled).
- Add `pkgs.git` to `modules/home/cli-tools.nix` so the `git` binary stays available independent of whether the dotfiles feature is configured.
- Add `homeConfigurations."tom@darwin"` (aarch64-darwin) to `flake.nix`, alongside the existing `tom@linux`, so this feature is actually buildable/usable on the user's Mac once Nix is installed there. The underlying configuration is unchanged between the two — only the per-system flake output is new.
- `users/tom.nix` sets `home.dotfiles.repoUrl = "";` with a TODO comment — **left as an open task for the user to fill in the actual git URL later**, not invented or guessed here.
- Update `README.md` to document the feature and the open `repoUrl` task.

## Capabilities

### New Capabilities
- `dotfiles-management`: automatic clone-and-stow of a personal dotfiles repository into `$HOME` as part of home-manager activation.

### Modified Capabilities
(none — `nix-flake-bootstrap` is untouched at the requirements level; the `tom@darwin` output and `cli-tools.nix`/`git.nix` changes are implementation details of the new `dotfiles-management` capability, not a change to what `nix-flake-bootstrap` itself promises)

## Impact

- Affected code: `modules/home/dotfiles.nix` (new), `modules/home/default.nix`, `modules/home/git.nix` (deleted), `modules/home/cli-tools.nix`, `users/tom.nix`, `flake.nix`, `README.md`.
- Depends on the already-implemented shared `modules/home` layer from `add-nix-flake-bootstrap`.
- No live host or remote exists yet, and Nix is still not installed on this development machine, so the activation script's actual clone/stow behavior can only be verified by manual review here, not executed — same constraint as the two prior changes.
- `~/dotfiles` already exists on this machine with real commit history; the activation script's "clone only if missing" behavior is required precisely so this change never touches that existing checkout.
- The `git` config change is user-visible: anyone relying on `programs.git.userName`/`userEmail` being set via Nix will instead need `~/dotfiles/git/.gitconfig` (or `home.dotfiles.repoUrl` configured) to get a working git identity — there is no fallback once `modules/home/git.nix` is removed.
