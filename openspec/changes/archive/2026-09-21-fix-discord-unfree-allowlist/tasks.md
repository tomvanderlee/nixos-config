## 1. Fix the allowlist

- [x] 1.1 In `lib/unfree-allowlist.nix`, add `"discord-unwrapped"` to the list alongside the existing `"discord"` entry.

## 2. Validate

- [x] 2.1 Run `openspec validate fix-discord-unfree-allowlist --strict` and confirm it passes.
- [x] 2.2 Run `nix build ".#homeConfigurations.\"tom@linux\".activationPackage" --dry-run` (no `NIXPKGS_ALLOW_UNFREE` override) and confirm it no longer fails with an unfree-license error for Discord, and that Discord's store paths appear in the plan.
- [x] 2.3 Run `nix flake check` and confirm it still passes with no new evaluation errors.
