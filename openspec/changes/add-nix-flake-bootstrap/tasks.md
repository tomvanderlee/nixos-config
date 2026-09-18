## 1. Flake scaffold

- [x] 1.1 Create `flake.nix` with `nixpkgs` (nixos-unstable) and `home-manager` (following `nixpkgs`) inputs, and an `outputs` function that imports `lib` and wires `nixosConfigurations`, `homeConfigurations`, `formatter`, and `devShells` — verify with `nix flake metadata` succeeding without errors (**nix not installed locally — command-level verification deferred, see note below**)
- [x] 1.2 Add `.gitignore` for `result`/`result-*` symlinks — verify `nix build` output doesn't get tracked by `git status`

## 2. Shared lib helpers

- [x] 2.1 Create `lib/mkNixos.nix` wrapping `nixpkgs.lib.nixosSystem`, taking `{ hostname, system ? "x86_64-linux", users ? [ "tom" ], extraModules ? [] }`, including `modules/nixos/common.nix`, `../hosts/${hostname}`, and `home-manager.nixosModules.home-manager` with `home-manager.users.<u> = import ../users/${u}.nix` for each user, and `specialArgs = { inherit inputs; }` — verify by importing it in a `nix repl` and checking it returns a function (**deferred, no local nix**)
- [x] 2.2 Create `lib/mkHome.nix` wrapping `home-manager.lib.homeManagerConfiguration`, taking `{ username, system, extraModules ? [] }`, using `pkgs = nixpkgs.legacyPackages.${system}` and `modules = [ ../users/${username}.nix ] ++ extraModules` — verify the same way (**deferred, no local nix**)
- [x] 2.3 Create `lib/default.nix` aggregating both as `{ mkNixos, mkHome }` given `{ inputs }` — verify `flake.nix` can `import ./lib { inherit inputs; }` without eval errors (**deferred, no local nix**)

## 3. Shared NixOS module

- [x] 3.1 Create `modules/nixos/common.nix` with `nix.settings.experimental-features = [ "nix-command" "flakes" ]`, a `tom` user skeleton (`isNormalUser = true`, `extraGroups = [ "wheel" ]`, `shell = pkgs.zsh`), default locale/timezone, and `nix.gc` policy — verify it evaluates standalone via `nix eval --file modules/nixos/common.nix` (or as part of the template host eval in task 5) (**deferred, no local nix**)

## 4. Shared home-manager profile

- [x] 4.1 Create `modules/home/git.nix` with `programs.git.enable = true`, `userName`, and `userEmail` sourced from options set in `users/tom.nix` (not hardcoded in the module itself), plus `init.defaultBranch = "main"` and `pull.rebase = true`
- [x] 4.2 Create `modules/home/shell.nix` with `programs.zsh.enable = true` (`autosuggestion.enable`, `syntaxHighlighting.enable`), `programs.starship.enable = true`, and `programs.direnv.enable = true` with `nix-direnv.enable = true`
- [x] 4.3 Create `modules/home/editor.nix` with `programs.neovim.enable = true`, `defaultEditor = true`, `vimAlias = true`
- [x] 4.4 Create `modules/home/cli-tools.nix` with `home.packages` including `ripgrep`, `fd`, `bat`, `eza`, `jq`, `fzf`, `tree`
- [x] 4.5 Create `modules/home/default.nix` importing the four modules above — verify by building `homeConfigurations."tom@linux"` in task 6 and confirming all four programs appear in the activation package (**deferred, no local nix**)

## 5. User identity module

- [x] 5.1 Create `users/tom.nix` setting `home.username = "tom"`, `home.homeDirectory = if pkgs.stdenv.isDarwin then "/Users/tom" else "/home/tom"`, `programs.git.userEmail = "t0m.vd.l33@gmail.com"`, `home.stateVersion` (pin to the current home-manager release), and importing `modules/home` — verify it evaluates under both a NixOS host context and standalone `mkHome` without error (**deferred, no local nix; stateVersion pinned to "24.05" — confirm/bump to your actual install-time release before first activation**)

## 6. Standalone home-manager output

- [x] 6.1 Add `homeConfigurations."tom@linux" = lib.mkHome { username = "tom"; system = "x86_64-linux"; };` to `flake.nix` — verify with `nix build .#homeConfigurations."tom@linux".activationPackage` succeeding without `--impure` (**deferred, no local nix**)

## 7. NixOS host template (copy-source only)

- [x] 7.1 Create `hosts/template/configuration.nix` with placeholders/comments for `networking.hostName`, boot loader choice, and `system.stateVersion`, importing nothing that requires real hardware
- [x] 7.2 Create `hosts/template/hardware-configuration.nix` as a stub importing `(modulesPath + "/installer/scan/not-detected.nix")` with commented example `fileSystems`/`boot.initrd.availableKernelModules` entries, clearly marked as "replace with the output of `nixos-generate-config`"
- [x] 7.3 Confirm `hosts/template` is not referenced by any `nixosConfigurations` entry in `flake.nix` — verify by grepping `flake.nix` for `template` and finding no matches (grep confirmed: only a comment mentions "template", no output reference)

## 8. Repo tooling

- [x] 8.1 Add `formatter.<system> = pkgs.nixfmt-rfc-style;` to `flake.nix` — verify with `nix fmt` running successfully across the repo (**deferred, no local nix**)
- [x] 8.2 Add `devShells.default` with `statix` and `deadnix` available — verify `nix develop -c statix check .` and `nix develop -c deadnix .` both run (**deferred, no local nix**)

## 9. Validation

- [x] 9.1 Run `nix flake check` and confirm it passes without `--impure`, covering `lib`, `homeConfigurations."tom@linux"`, `formatter`, and `devShells` (**blocked — nix not installed locally; no fallback verification possible. Run this once Nix is available.**) (run by the user on a Linux machine with Nix, 2026-09-18: `nix flake check` passed with no errors — only benign warnings, `nixfmt-rfc-style`/missing `apps.*.meta` since fixed in a later change, and the expected "omitted incompatible systems" notice since the run was on a single system without `--all-systems`)
- [x] 9.2 Manually review `flake.nix` and confirm `nixosConfigurations` is empty (or absent) in this change, per the design decision not to expose the unbuilt template (confirmed: `nixosConfigurations = { };`)

## 10. Documentation

- [x] 10.1 Write `README.md` documenting the repo layout, the NixOS install workflow (manual partition/format → `nixos-generate-config` → copy `hosts/template` → `nixos-install --flake`), and the standalone workflow (install Nix → `home-manager switch --flake`) — verify by following each documented command sequence mentally against the actual files created in this change for consistency
- [x] 10.2 Note in the README, as explicit follow-up items not covered by this change: pushing the repo to a remote (required before `nixos-install` can clone it), adding a real NixOS host, adding nix-darwin for a real Mac host, and adding secrets management

## 11. Commit

- [x] 11.1 `git add` all new files (`flake.nix`, `flake.lock`, `lib/`, `modules/`, `hosts/`, `users/`, `README.md`, `.gitignore`) and create the initial commit — verify with `git status` showing a clean tree and `git log` showing the commit, which also makes the flake's files visible to the Nix evaluator for the first time (**note: no `flake.lock` yet — it can only be generated by `nix flake lock`/`nix flake check`, which require Nix; committed without it, will be created on first `nix` invocation**) (committed as `d7acead`, staged/committed by the user due to a sandbox restriction on `.git/index.lock`; `git status` confirms a clean tree, `git log` confirms the commit)

---

**Verification note:** Nix is not installed on this machine (confirmed via `which nix`), so none of the `nix flake check` / `nix build` / `nix repl` / `nix fmt` / `nix develop` verification commands above could actually be run. Per explicit user decision, all file-creation tasks are marked complete based on careful manual construction against the Nix/home-manager module system semantics, but **task 9.1 (the full `nix flake check`) remains unexecuted and should be run as soon as Nix is available** — treat that as the real acceptance gate for this change, not the individual checkboxes above.
