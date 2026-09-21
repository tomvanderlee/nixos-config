## Why

The shared home-manager profile provisions chat/communication/music GUI apps (`desktop-applications`) and CLI tooling (`developer-environment`), but has no web browser and no password manager. Tom wants Firefox and Bitwarden (desktop app + CLI) available on any machine built from this flake without installing them by hand.

## What Changes

- Add `pkgs.firefox` and nixpkgs' current Bitwarden desktop client package (`pkgs.bitwarden-desktop` — the old `bitwarden` attribute was renamed upstream) to `modules/home/desktop-apps.nix`'s cross-platform app list, following the existing `lib.meta.availableOn` filtering pattern.
- Add `pkgs.bitwarden-cli` to `modules/home/dev-tools.nix`'s CLI tool list, following the same pattern already used for `claude-code`.
- No `lib/unfree-allowlist.nix` change: verified via `nix eval` against the flake's pinned `nixos-unstable` nixpkgs that `firefox` (MPL-2.0), `bitwarden-desktop` (GPL-3.0), and `bitwarden-cli` (GPL-3.0) are all free-licensed today, so `nixpkgs.config.allowUnfreePredicate` needs no new entries.
- Explicitly **not** in scope (per user decision): no OS/XDG default-browser association (`xdg.mimeApps`) and no `programs.firefox` extension/policy management — Firefox extensions, including Bitwarden's, are expected to sync in via Firefox Sync login.
- **BREAKING**: none — additive only.

## Capabilities

### New Capabilities
(none)

### Modified Capabilities
- `desktop-applications`: add a requirement that Firefox and the Bitwarden desktop client are provisioned via the shared home profile alongside the existing Slack/Discord/Spotify/teams-for-linux apps.

(`developer-environment` is unaffected at the requirement level: adding `bitwarden-cli` is already covered by its existing requirement that the shared profile "SHALL include the user's evidenced most-used CLI and client tools," the same reasoning used previously for `claude-code` — no requirement text changes needed.)

## Impact

- **Affected code**: `modules/home/desktop-apps.nix` (add firefox + bitwarden-desktop to `crossPlatformApps`), `modules/home/dev-tools.nix` (add bitwarden-cli to the CLI package list).
- **Not affected**: `lib/unfree-allowlist.nix`, `lib/mkHome.nix`, `lib/mkNixos.nix` — all three new packages are free-licensed, so the existing `allowUnfreePredicate` wiring needs no changes.
- **Dependencies**: nixpkgs' `firefox`, `bitwarden-desktop`, and `bitwarden-cli` packages (all already present in the pinned `nixos-unstable` input; no new flake inputs).
- **Platforms**: all three packages have `aarch64-darwin` and `x86_64-linux`/`aarch64-linux` builds in nixpkgs today, so they're expected to be included on every currently-relevant target (`tom@linux`, `tom@darwin`) via the existing `lib.meta.availableOn` filter — no platform-specific gating (like teams-for-linux's Linux-only restriction) is needed for this change.
- **Known limitation, out of scope**: no default-browser (XDG mime) or Firefox extension/policy management, by explicit user decision — see "What Changes".
