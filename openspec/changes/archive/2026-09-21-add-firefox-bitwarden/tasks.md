## 1. Add Firefox and Bitwarden desktop app to the shared home profile

- [x] 1.1 In `modules/home/desktop-apps.nix`, add `pkgs.firefox` and `pkgs.bitwarden-desktop` to `crossPlatformApps` and verify `nix eval --impure --expr 'let pkgs = import <nixpkgs> {}; in [ pkgs.firefox pkgs.bitwarden-desktop ]'` resolves both packages without error.
- [x] 1.2 Verify no `lib/unfree-allowlist.nix` change is needed by confirming `pkgs.firefox.meta.unfree` and `pkgs.bitwarden-desktop.meta.unfree` are both `false` against the flake's pinned nixpkgs (already confirmed during proposal against `nixos-unstable`; re-check if the flake lock has moved since).

## 2. Add Bitwarden CLI to the shared developer tooling

- [x] 2.1 In `modules/home/dev-tools.nix`, add `pkgs.bitwarden-cli` to the `home.packages` list (plain list entry, consistent with `gh`/`tmux`/etc. — no `lib.meta.availableOn` guard needed since `claude-code` is the only currently-gated entry and `bitwarden-cli` has broad platform support).

## 3. Validate

- [x] 3.1 Run `openspec validate add-firefox-bitwarden --strict` and confirm it passes.
- [x] 3.2 Run `home-manager build --flake .#tom@linux` (or the equivalent for the platform available) and confirm the build succeeds with firefox, bitwarden-desktop, and bitwarden-cli present in the resulting profile's `home.packages`.
- [x] 3.3 Run `nix flake check` and confirm it passes with no new evaluation errors.
