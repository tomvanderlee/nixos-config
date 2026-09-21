## 1. Replace deprecated `stdenv.isDarwin`/`isLinux`

- [x] 1.1 In `users/tom.nix`, replace `pkgs.stdenv.isDarwin` with `pkgs.stdenv.hostPlatform.isDarwin` in the `home.homeDirectory` conditional — verify by reading the file back and confirming the Darwin/Linux home path logic is otherwise unchanged
- [x] 1.2 In `modules/home/dotfiles.nix`, replace `pkgs.stdenv.isDarwin`/`pkgs.stdenv.isLinux` with `pkgs.stdenv.hostPlatform.isDarwin`/`.isLinux` in `platformDefaultExcludes` — verify by reading the file back and confirming the excluded-package lists (`iterm2` on non-Darwin; `herbstluftwm`/`xorg` on non-Linux) are unchanged
- [x] 1.3 Verify via `grep -rn "stdenv.isDarwin\|stdenv.isLinux" --include="*.nix" .` that no remaining usage exists outside `hosts/template/` (if any) (verified: zero matches anywhere in the repo, including `hosts/template/`)

## 2. Pin Neovim provider defaults explicitly

- [x] 2.1 In `modules/home/editor.nix`, add `withRuby = true;` and `withPython3 = true;` to the `programs.neovim` block — verify by reading the file back

## 3. Validate

- [x] 3.1 Run `nix flake check` (or `nixos-rebuild build`/`home-manager build`, wherever Nix is available) and confirm the four deprecation warnings no longer appear and all outputs still evaluate cleanly (blocked — Nix is not installed on this machine; run this once Nix is available, e.g. on the real host where the original warnings were observed — this is the real acceptance gate, not the individual checkboxes above). Reviewed manually instead: all three edited files were read back and are syntactically well-formed; `pkgs.stdenv.hostPlatform.isDarwin`/`.isLinux` is a straight rename of the same attribute path nixpkgs' `stdenv` exposes, and `withRuby`/`withPython3 = true;` matches the exact value the warning said was already in effect, so no other behavior should change
