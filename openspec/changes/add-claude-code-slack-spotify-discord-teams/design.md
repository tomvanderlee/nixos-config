## Context

See proposal.md - Why/What Changes for motivation. Two constraints shape this design:

- `lib/mkHome.nix` builds standalone `homeConfigurations` by passing a pre-instantiated `pkgs = inputs.nixpkgs.legacyPackages.${system}` directly into `homeManagerConfiguration`. Because `pkgs` is supplied rather than left for home-manager to construct, the home-manager `nixpkgs.config` module option has no effect there - unfree gating has to happen when `pkgs` itself is built.
- `lib/mkNixos.nix` builds NixOS hosts with `home-manager.useGlobalPkgs = true`, so the home-manager profile shares whatever `pkgs` the NixOS module system constructs - there, a `nixpkgs.config` module option set anywhere in the module list does take effect.
- No package in this repo has ever needed to vary by architecture before; `modules/home/dotfiles.nix` conditions on `isDarwin`/`isLinux` for stow directories, not on `pkgs.stdenv.hostPlatform` for a Nix package.

## Goals / Non-Goals

**Goals:**
- One shared mechanism for "this package isn't supported on this system, skip it" that works for both current architectures (x86_64-linux, aarch64-darwin) and any future host without per-package manual bookkeeping.
- Unfree package access scoped to exactly the packages this change needs.

**Non-Goals:**
- Adding nix-darwin or Homebrew support for nicer macOS app delivery (tracked separately in the README).
- Standing up a real `aarch64-linux` host to test the skip behavior on - none exists in this repo today; the mechanism is verified by evaluating the existing configs and reasoning about `meta.platforms`, not by building on that architecture.

## Decisions

**Use `lib.meta.availableOn pkgs.stdenv.hostPlatform pkg`, filtered over a candidate list, instead of hand-written per-package platform conditionals.**
`lib.meta.availableOn` is nixpkgs' own check against a derivation's `meta.platforms`/`meta.badPlatforms`, so it stays correct automatically if nixpkgs adds or drops platform support for one of these packages later. The alternative - hardcoding e.g. `lib.optional (system == "x86_64-linux") pkgs.discord` - would silently go stale and requires knowing each package's exact supported-platform list up front.

**Scope unfree access via `nixpkgs.config.allowUnfreePredicate` backed by a single `lib/unfree-allowlist.nix`, not blanket `allowUnfree = true`.**
Chosen explicitly over the blanket option: it names exactly `slack`, `discord`, `spotify`, `claude-code` rather than permitting any future unfree package by default, matching this repo's existing preference for minimal, explicit scoping (see `dotfiles.nix`'s platform-exclude list and its accompanying comment). The list is a single file imported by both `lib/mkHome.nix` and `lib/mkNixos.nix` so the two builders can't drift out of sync.

**`lib/mkHome.nix` switches from `inputs.nixpkgs.legacyPackages.${system}` to `import inputs.nixpkgs { inherit system; config.allowUnfreePredicate = ...; }`.**
This is the minimal change that makes unfree gating actually take effect for standalone home-manager, per the Context constraint above. Alternative considered: leave `pkgs` as `legacyPackages` and instead set `nixpkgs.config` as a home-manager module option - rejected because home-manager ignores that option once `pkgs` is passed in directly (it would silently do nothing, which is worse than an explicit fix here).

**`lib/mkNixos.nix` sets the same predicate via a small inline module prepended to its `modules` list**, rather than editing `modules/nixos/common.nix`. Keeping it in the builder (alongside where `mkHome.nix` does the equivalent) keeps both unfree-gating call sites next to each other and next to the shared allowlist, instead of splitting the concern across `lib/` and `modules/nixos/`.

**`claude-code` is added to `modules/home/dev-tools.nix`, not the new `desktop-applications` capability.**
It's a CLI tool, and `developer-environment`'s existing requirement already generically covers "the shared profile SHALL include the user's evidenced most-used CLI and client tools" - no new requirement text is needed, just a package addition guarded by the same `lib.meta.availableOn` check for consistency.

**`teams-for-linux` gets an explicit `pkgs.stdenv.hostPlatform.isLinux` guard in addition to the `availableOn` filter**, rather than relying on `availableOn` alone.
Belt-and-suspenders: the product is Linux-only by design regardless of what nixpkgs' `meta.platforms` happens to list for it, so the explicit guard keeps behavior correct even if that metadata is ever loose or changes.

## Risks / Trade-offs

- **No local Nix to verify eval/build** → Mitigation: tasks.md verification steps target a machine with Nix installed; this is a pre-existing gap in this environment, not new to this change.
- **`lib.meta.availableOn` trusts nixpkgs' `meta.platforms` accuracy** → Mitigation: cross-checked against current nixpkgs metadata (Slack/Discord/Spotify unfree and missing `aarch64-linux`; `claude-code` unfree and available on all four systems; `teams-for-linux` free/GPL and broadly available) before writing this design; if nixpkgs metadata is ever wrong for a package, the filter fails closed (excludes it) rather than failing the build.
- **macOS apps come from nixpkgs' darwin builds, not Homebrew casks** → Mitigation: explicitly out of scope (see Non-Goals); flagged in proposal.md's Impact section as a known limitation.
