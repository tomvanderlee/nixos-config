## 1. Dotfiles module

- [x] 1.1 Create `modules/home/dotfiles.nix` defining `options.home.dotfiles.repoUrl` (string, default `""`) — verify by reading the option definition against the template in design.md
- [x] 1.2 Implement `config = lib.mkIf (cfg.repoUrl != "") { ... }` wrapping the feature so it's fully inert when unset — verify the `mkIf` condition guards both `home.packages` and `home.activation.dotfiles`
- [x] 1.3 Add `home.packages = [ pkgs.git pkgs.stow ];` inside the `mkIf` block — verify both packages are listed
- [x] 1.4 Implement `home.activation.dotfiles` using `lib.hm.dag.entryAfter [ "writeBoundary" ]`: clone `cfg.repoUrl` to `~/dotfiles` with `--recurse-submodules` only if `~/dotfiles/.git` doesn't already exist, using `$DRY_RUN_CMD` on the clone — verify the existence check precedes the clone and no unconditional clone/rm exists
- [x] 1.5 In the same activation script, loop over non-hidden top-level directories under `~/dotfiles` and run `stow -d ~/dotfiles -t <homeDirectory> <package>` per directory (via `$DRY_RUN_CMD`), with `|| echo "Warning: ..." >&2` so one failure doesn't abort the loop — verify the loop skips hidden entries (`case "$pkg_name" in .*) continue ;; esac`) and each `stow` call is independently fault-tolerant
- [x] 1.6 Add `modules/home/dotfiles.nix` to `modules/home/default.nix`'s imports — verify by grep confirming the import is present

## 2. Remove home-manager git config management

- [x] 2.1 Delete `modules/home/git.nix` — verify the file no longer exists
- [x] 2.2 Remove `./git.nix` from `modules/home/default.nix`'s imports — verify by grep confirming no reference to `git.nix` remains in that file
- [x] 2.3 Remove the `programs.git = { userName = ...; userEmail = ...; };` block from `users/tom.nix` — verify by reading the file and confirming no `programs.git` reference remains

## 3. Keep git available independent of the dotfiles feature

- [x] 3.1 Add `pkgs.git` to `modules/home/cli-tools.nix`'s package list — verify by reading the updated package list

## 4. Darwin home-manager output

- [x] 4.1 Add `homeConfigurations."tom@darwin" = lib.mkHome { username = "tom"; system = "aarch64-darwin"; };` to `flake.nix`, alongside the existing `tom@linux` entry — verify by grep confirming both entries exist

## 5. Open task: repo URL

- [x] 5.1 In `users/tom.nix`, add `home.dotfiles.repoUrl = "";` with a comment marking it as an intentional placeholder for the user to fill in later — verify the value is an empty string, not a guessed or invented URL, and the comment is present (left blank as specified; the user has since supplied the real URL directly — `home.dotfiles.repoUrl = "https://git.tomvanderlee.com/dotfiles"` — so this open item is now resolved, not just scaffolded)

## 6. Documentation

- [x] 6.1 Update `README.md` to document the dotfiles feature (what it does, that it's opt-in via `home.dotfiles.repoUrl`) and note the open task of filling in the real URL — verify by reading the updated section for consistency with the actual module behavior (also fixed two now-stale mentions: the layout line still listing "git" as a managed module, and the non-NixOS section only mentioning `tom@linux`)

## 7. Validation

- [x] 7.1 Run `nix flake check` and confirm the new module and `tom@darwin` output evaluate without error (blocked — Nix is not installed on this machine; run this once Nix is available, e.g. via a real install or CI — this is the real acceptance gate, not the individual checkboxes above) (run by the user on a Linux machine with Nix, 2026-09-18: passed with no errors)
- [x] 7.2 Manually trace through each spec scenario in `specs/dotfiles-management/spec.md` against the implemented module, confirming each is satisfied by inspection given #7.1 cannot run locally (all 7 scenarios traced and satisfied: `mkIf` gates the opt-in behavior; the `.git`-existence guard means an existing checkout is never touched and the clone branch uses `--recurse-submodules`; the directory-only glob plus `case .*) continue` excludes both non-directory entries and hidden directories from being treated as packages; each `stow` call's `|| echo "Warning..."` keeps one conflict from aborting the loop under `set -e`)

---

**Verification note:** as with the two prior changes, Nix is not installed on this machine, so task 7.1 (`nix flake check`) could not be executed and remains the outstanding acceptance gate for all three changes now. `shellcheck` was unavailable locally in the prior change too, but this change's activation script logic is plain POSIX-ish shell embedded in a Nix string (not a standalone script file), so there was no separate file to syntax-check with `bash -n` either — review here was manual/by-inspection only.
