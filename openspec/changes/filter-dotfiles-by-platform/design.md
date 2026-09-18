## Context

See proposal.md - Why. `modules/home/dotfiles.nix` currently loops over every non-hidden top-level directory in the cloned external dotfiles repo and stows all of them unconditionally (lines 22-28). The only existing platform-branching precedent in this codebase is the simple `if pkgs.stdenv.isDarwin then ... else ...` in `users/tom.nix:6`. Only two real `homeConfigurations` exist today (`tom@linux`, `tom@darwin` in `flake.nix:44-53`); no NixOS hosts are defined yet (`hosts/` has only `template`). The known current package inventory in the external repo includes `iterm2` (Darwin-only), and `herbstluftwm` + `xorg` (Linux-only).

## Goals / Non-Goals

**Goals:**
- Skip stowing packages that are known to be irrelevant to the current platform, using a minimal, easily-extended mechanism.
- Preserve an escape hatch so a host can exclude additional packages without further code changes if the external repo's contents change.
- Keep all changes scoped to `modules/home/dotfiles.nix`; no changes to the external dotfiles repo, `flake.nix`, or host definitions.

**Non-Goals:**
- Building a full per-host "which programs/WMs does this host use" model. The current problem is fully explained by OS (Darwin vs. Linux), so no new host-level option or metadata is introduced.
- Handling a future NixOS host that runs a desktop environment (e.g. GNOME, per `add-gnome-desktop`) but would still be Linux and thus still match the Linux exclude branch for `herbstluftwm`/`xorg` as "relevant." No such host exists yet; if it becomes a real problem later, the `excludePackages` escape hatch this change adds already covers it per-host.

## Decisions

**Decision: a small built-in platform-keyed exclude list, plus an `excludePackages` override option, computed with `pkgs.stdenv.isDarwin`/`isLinux`.**

Inside `modules/home/dotfiles.nix`, add:
```nix
options.home.dotfiles.excludePackages = lib.mkOption {
  type = lib.types.listOf lib.types.str;
  default = [ ];
  description = "Names of dotfiles stow packages to always skip, in addition to built-in platform defaults.";
};
```
and a `let`-bound list combining a small built-in default (`iterm2` when not Darwin; `herbstluftwm`, `xorg` when not Linux) with `cfg.excludePackages`. Pass the combined list into the activation script via `lib.escapeShellArgs` as a bash array, and check membership in the existing `for pkg in ...` loop before calling `stow`, skipping with a warning message (mirroring the existing stow-failure warning style at line 27) instead of silently stowing.

Alternatives considered:
- **Marker-file convention in the external dotfiles repo** (e.g. each stow package declares its own target platform via a `.nix-platform` file that `dotfiles.nix` reads). This would keep nix-config fully generic and free of package-name knowledge, matching the original design philosophy most closely. Rejected because the dotfiles repo lives outside this git repository and is not something this change can edit or verify; it would also require the mechanism to handle a missing/malformed marker file gracefully, adding complexity for no immediate benefit over a 3-name list.
- **Fully generic attrs-based platform-mapping option** (e.g. `home.dotfiles.packagePlatforms = { darwin = [...]; linux = [...]; }`), configured per-host. Rejected as overengineering relative to the current need (only two platforms, three known mismatched packages); the simpler list-plus-override captures the same override capability with far less surface area.
- **Do nothing (status quo)**: the previously accepted "harmless unused symlinks" trade-off. Rejected per the user's explicit request; this change supersedes that decision.

## Risks / Trade-offs

- [Reintroducing external-repo package-name knowledge into nix-config, which the original design explicitly avoided] → Mitigation: kept minimal (3 names in one `let` binding) and overridable via `excludePackages`, so it degrades gracefully if the external repo's package list changes rather than silently breaking.
- [A future Linux host that both is Linux and doesn't want `herbstluftwm`/`xorg` (e.g. a GNOME NixOS host) would still get them stowed, since the built-in default only branches on Darwin vs. Linux, not on WM in use] → Mitigation: no such host exists yet; the `excludePackages` option already provides a per-host override once one does.
