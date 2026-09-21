## Why

The shared home-manager profile currently provisions only CLI/client tooling; there is no way to get everyday desktop GUI applications (chat, communication, music) or the Claude Code CLI onto a machine built from this flake without installing them by hand outside of Nix. The user wants Claude Code, Slack, Spotify, Discord, and [teams-for-linux](https://ismaelmartinez.github.io/teams-for-linux/) declared in the config, with the understanding that several of these are unfree-licensed and some (Discord, Spotify, Slack) do not have `aarch64-linux` builds in nixpkgs today — an unsupported package must be skipped rather than break evaluation on that architecture.

## What Changes

- Add a new `modules/home/desktop-apps.nix` home-manager module provisioning Slack, Discord, Spotify, and teams-for-linux, filtered through `lib.meta.availableOn` so any package unsupported on the current system/architecture is silently omitted instead of failing the build; teams-for-linux is additionally restricted to Linux only.
- Add `claude-code` to the existing `modules/home/dev-tools.nix` CLI tool list, guarded the same way.
- Introduce a shared `lib/unfree-allowlist.nix` naming exactly the unfree packages this change adds (`slack`, `discord`, `spotify`, `claude-code`; teams-for-linux is GPL-licensed and needs no allowance), and wire `nixpkgs.config.allowUnfreePredicate` from it in both `lib/mkHome.nix` (standalone home-manager) and `lib/mkNixos.nix` (NixOS + home-manager), since neither currently permits any unfree package.
- **BREAKING**: none — additive only; existing configurations continue to evaluate and activate unchanged aside from gaining new optional packages.

## Capabilities

### New Capabilities
- `desktop-applications`: provisioning of user-facing desktop GUI applications (Slack, Discord, Spotify, teams-for-linux) through the shared home-manager profile, including the rule that a package unsupported on the current system is skipped rather than causing failure.

### Modified Capabilities
(none — adding `claude-code` to the shared CLI toolset is already covered by `developer-environment`'s existing requirement that the shared profile "SHALL include the user's evidenced most-used CLI and client tools"; no requirement text changes.)

## Impact

- **Affected code**: `lib/mkHome.nix`, `lib/mkNixos.nix` (new `lib/unfree-allowlist.nix` dependency), `modules/home/default.nix` (new import), `modules/home/desktop-apps.nix` (new file), `modules/home/dev-tools.nix`.
- **Dependencies**: relies on nixpkgs' unfree-licensed `slack`, `discord`, `spotify`, `claude-code` packages and the free `teams-for-linux` package; no new flake inputs.
- **Platforms**: applies to both `homeConfigurations` (`tom@linux` = x86_64-linux, `tom@darwin` = aarch64-darwin) and any future NixOS host built via `lib/mkNixos.nix`. On `aarch64-darwin`, `teams-for-linux` is intentionally excluded (Linux-only product); on any future `aarch64-linux` host, Discord/Spotify/Slack are expected to be excluded automatically since nixpkgs does not currently build them for that platform.
- **Known limitation, out of scope**: this repo has no nix-darwin/Homebrew integration yet (tracked separately in the README as a follow-up), so on macOS these apps are provisioned from nixpkgs' darwin builds only, not Homebrew casks.
- **Verification gap**: no local Nix installation in this environment, so `nix flake check` / `home-manager build` cannot be run here; verification must happen on a machine with Nix installed (see tasks.md).
