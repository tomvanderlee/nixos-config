## Why

`nixos-rebuild`/`home-manager switch` on a real host now emits four evaluation warnings: `stdenv.isDarwin`/`stdenv.isLinux` are deprecated in favor of `stdenv.hostPlatform.isDarwin`/`.isLinux`, and `programs.neovim.withRuby`/`withPython3` warn that their default is changing and asks for an explicit value while `home.stateVersion` stays below "26.05". Left unset, these warnings will keep appearing on every activation, and the neovim providers' actual default would change out from under this flake the moment `stateVersion` is ever bumped, with no record of that being an intentional choice.

## What Changes

- Replace every `pkgs.stdenv.isDarwin`/`pkgs.stdenv.isLinux` usage with `pkgs.stdenv.hostPlatform.isDarwin`/`.isLinux` (`users/tom.nix`, `modules/home/dotfiles.nix`). Pure rename with identical semantics — no behavior change.
- Explicitly set `programs.neovim.withRuby = true;` and `programs.neovim.withPython3 = true;` in `modules/home/editor.nix`, pinning today's legacy-default behavior on purpose rather than leaving it implicit and version-dependent. No behavior change.

## Capabilities

### New Capabilities
(none)

### Modified Capabilities
(none — every change here preserves current externally observable behavior exactly; only the deprecated attribute names and an implicit default become explicit. `.openspec.yaml` sets `skip_specs: true` accordingly.)

## Impact

- Affected code: `users/tom.nix`, `modules/home/dotfiles.nix`, `modules/home/editor.nix`.
- Affects every `homeConfigurations`/`nixosConfigurations` output built from the shared home profile, on both NixOS and Darwin.
- Out of scope: the "Git tree is dirty" notice in the pasted warnings is expected uncommitted-changes noise from evaluating a local checkout, not a deprecation — not addressed here. Also out of scope: bumping `home.stateVersion` itself, which would pull in a much broader set of home-manager default changes beyond these two neovim options.
