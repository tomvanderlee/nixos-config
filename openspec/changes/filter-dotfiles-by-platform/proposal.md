## Why

The dotfiles activation in `modules/home/dotfiles.nix` stows every top-level package directory from the external personal dotfiles repo into `$HOME` unconditionally, with no platform filtering. In practice this means macOS-only config (`iterm2`, for iTerm2) gets stowed on the Linux home-manager target, and Linux X11-only config (`herbstluftwm`, `xorg`) gets stowed on the Darwin machine — producing dead, irrelevant symlinks. This was previously an explicitly accepted trade-off (see the archived `add-dotfiles-stow-bootstrap` change's design non-goals, reaffirmed by `add-gnome-desktop`'s out-of-scope note), but the user now wants platform-irrelevant packages skipped, so this change supersedes that earlier "accept the risk" decision.

## What Changes

- `modules/home/dotfiles.nix` gains a new `home.dotfiles.excludePackages` option (list of package names to skip regardless of platform), as a manual per-host escape hatch.
- The module computes a small built-in default exclude set from the current known platform mismatches, using the same `pkgs.stdenv.isDarwin`/`isLinux` pattern already used in `users/tom.nix`: `iterm2` is skipped when not on Darwin; `herbstluftwm` and `xorg` are skipped when not on Linux.
- The stow activation loop skips any package in the combined exclude set (built-in + `excludePackages`), printing a visible "skipped — not relevant on this platform" message instead of silently stowing it. Packages not in the exclude set continue to stow exactly as before.

## Capabilities

### Modified Capabilities
- `dotfiles-management`: adds a requirement that platform-irrelevant dotfiles packages (built-in defaults or explicitly configured via `excludePackages`) are skipped during stow, rather than always stowing every top-level package directory.

## Impact

- **Code**: `modules/home/dotfiles.nix` (new option, exclude-set computation, activation script loop).
- **Specs**: `openspec/specs/dotfiles-management/spec.md` gains a new requirement; existing requirements (opt-in via repo URL, no re-clone, package-to-symlink mapping, per-package fault isolation) are unaffected.
- **Prior decisions superseded**: the "no filtering, accept harmless unused symlinks" non-goal recorded in the archived `add-dotfiles-stow-bootstrap` design and reaffirmed in `add-gnome-desktop` no longer holds; this change intentionally reverses it.
- No changes to `flake.nix`, host definitions, or the external dotfiles repo itself.
