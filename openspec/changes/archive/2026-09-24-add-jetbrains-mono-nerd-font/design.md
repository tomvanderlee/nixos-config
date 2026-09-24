## Context

See proposal.md - Why. This is a single-package addition to `modules/home/`, the shared cross-platform profile described in `CLAUDE.md`. That file documents two established patterns this design reuses rather than inventing new ones:
- `lib.meta.availableOn pkgs.stdenv.hostPlatform`, filtered over a candidate list, for package availability differences (used today in `modules/home/desktop-apps.nix`).
- Platform checks (`pkgs.stdenv.hostPlatform.isLinux`/`isDarwin`) for platform-only differences.

Confirmed against the pinned `nixpkgs` (`nixos-unstable`, see `flake.nix`): `pkgs.nerd-fonts.jetbrains-mono` exists, but its `meta.platforms` excludes `x86_64-darwin` while including `aarch64-darwin`, `x86_64-linux`, and `aarch64-linux` (and effectively everything else). None of this flake's actual `homeConfigurations` (`tom@linux` = `x86_64-linux`, `tom@darwin` = `aarch64-darwin`) or `nixosConfigurations` (`test-vm` = `aarch64-linux`) target `x86_64-darwin` today, so this gap is latent, not currently triggered - but the flake's `devShells`/`formatter` outputs do cover `x86_64-darwin` via `forAllSystems`, and a future `homeConfigurations."tom@darwin-intel"` (or similar) would hit it immediately without a guard.

Font delivery differs by platform in home-manager itself, independent of anything this repo needs to write:
- On Linux, fontconfig-based apps discover fonts placed under `home.packages` only once `fonts.fontconfig.enable` is on. Home-manager defaults that option to `nixosConfig.fonts.fontconfig.enable` when running as a NixOS submodule with `useUserPackages` (this flake's `mkNixos` wiring) - which is `true` by NixOS's own default - but defaults to `false` for a standalone (non-NixOS) activation, where `nixosConfig` is null.
- On Darwin, home-manager's built-in `targets.darwin.fonts` module (unconditional on `pkgs.stdenv.hostPlatform.isDarwin`, not gated by `fonts.fontconfig.enable`) already rsyncs any font found in `home.packages` into `~/Library/Fonts/HomeManager` on every activation.

## Goals / Non-Goals

**Goals:**
- Provision the JetBrains Mono Nerd Font through the shared home-manager profile on every platform the pinned nixpkgs supports it on.
- Make the font discoverable by fontconfig-based apps (Ghostty, Neovim's GUI-adjacent tooling) on Linux, standalone or NixOS-hosted, without relying on the NixOS-submodule-derived default.
- Skip cleanly, not fail evaluation, on a platform without a supported build.

**Non-Goals:**
- Configuring Ghostty or Neovim to actually *use* the font (`font-family` in Ghostty's config, `guifont`, etc.) - those are dotfiles-repo-owned per `modules/home/dotfiles.nix`'s Stow model, outside this shared profile's remit.
- Provisioning any other typeface. The `fonts` capability is scoped to this one font for now; broadening it is a future change.
- Any NixOS-level (`modules/nixos/common.nix`) font configuration - system-level `fonts.packages` is a separate, unused mechanism here; everything goes through the home-manager profile per this repo's existing GUI-package pattern.

## Decisions

**New `modules/home/fonts.nix`, imported from `modules/home/default.nix`.** Mirrors the existing per-concern module layout (`desktop-apps.nix`, `editor.nix`, etc.) rather than folding the font into an existing file - fonts are a distinct concern from GUI applications or the editor toolchain, and a dedicated `fonts` capability needs a dedicated spec-to-code mapping.

**Filter through `lib.meta.availableOn pkgs.stdenv.hostPlatform` even for a single-package list.** Alternative considered: skip the filter since only one font package exists today and none of the currently-defined outputs hit the unsupported platform. Rejected because the gap is real (confirmed above) and the guard is a one-line reuse of an already-established, already-imported pattern (`desktop-apps.nix` imports `lib` for the same purpose) - cheaper than the risk of a future Darwin-Intel host hitting an eval failure.

**Set `fonts.fontconfig.enable = true;` unconditionally (no `osConfig`/platform guard).** This option is home-manager-internal and platform-safe on its own: it's a no-op contributor on Darwin (fontconfig isn't the font-discovery path there; `targets.darwin.fonts` handles that unconditionally regardless of this option) and is idempotent on NixOS (already defaults to `true` there via the `useUserPackages` derivation). Setting it explicitly, rather than relying on that implicit default, documents the intent directly in this repo's own module and keeps standalone Linux behavior correct without depending on NixOS-side wiring. Alternative considered: gate it behind `pkgs.stdenv.hostPlatform.isLinux` for clarity - rejected as unnecessary ceremony since the option is inert (not merely ignored, but literally unused) on Darwin.

## Risks / Trade-offs

- [`nerd-fonts.jetbrains-mono` has no `x86_64-darwin` build in the pinned nixpkgs] → Mitigated by the `lib.meta.availableOn` filter; the package silently drops out there instead of failing `nix flake check` or a build, consistent with the `desktop-applications` capability's existing unsupported-package handling.
- [nixpkgs restructures or renames the `nerd-fonts.*` package set in a future `nixpkgs-unstable` bump] → Would surface as an eval error on the next `nix flake check` / `flake.lock` update, same exposure as any other pinned package reference in this repo; no special handling proposed here.
