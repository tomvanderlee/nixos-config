## Why

`lib/unfree-allowlist.nix` lists `"discord"`, but a real build of the shared home profile fails today with `error: Refusing to evaluate package 'discord-unwrapped-1.0.156' ... because it has an unfree license`. Discord's nixpkgs derivation is an FHS-env wrapper around an internal `discord-unwrapped` derivation (not exposed as a top-level `pkgs` attribute), and `nixpkgs.config.allowUnfreePredicate` checks `lib.getName pkg` against the allowlist by exact string — `"discord"` never matches `"discord-unwrapped"`, so the wrapped build is blocked. This was discovered and reproduced against unmodified `main` (via `git stash`) while verifying an unrelated change (`add-firefox-bitwarden`), so it predates and is independent of that work.

## What Changes

- Add `"discord-unwrapped"` to `lib/unfree-allowlist.nix`, alongside the existing `"discord"` entry (both names get checked at different points in the build — the wrapper and the inner FHS payload).
- **BREAKING**: none — this restores already-specified behavior (`desktop-applications` already requires Discord to be provisioned); it doesn't change what's provisioned or add anything new.

## Capabilities

### New Capabilities
(none)

### Modified Capabilities
(none — `desktop-applications`'s existing requirement already states the shared profile "SHALL include Slack, Discord, Spotify, teams-for-linux, Firefox, and the Bitwarden desktop client"; this change fixes a defect that was silently preventing that already-specified behavior from actually building, it doesn't change the requirement. `.openspec.yaml` sets `skip_specs: true` accordingly, matching the precedent in `fix-deprecation-warnings`.)

## Impact

- **Affected code**: `lib/unfree-allowlist.nix` only (one new list entry).
- **Not affected**: `modules/home/desktop-apps.nix`, `lib/mkHome.nix`, `lib/mkNixos.nix` — the predicate wiring itself is correct; only the allowlist's string entries were incomplete.
- **Verification note**: this environment is `aarch64-linux`, while `tom@linux` targets `x86_64-linux`, so a full realized build isn't possible here without emulation — verification is evaluation-only (`nix build ... --dry-run`), confirming the unfree-license error disappears and Discord's store paths resolve.
