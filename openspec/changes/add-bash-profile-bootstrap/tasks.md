## 1. Module

- [x] 1.1 Create `modules/home/bash-profile.nix` with a `pkgs.writeText` block for the `.bash_profile` content and a `home.activation.bashProfile` script that creates it via `install -m 644` only when `${config.home.homeDirectory}/.bash_profile` does not exist (`[ ! -e ... ]`) — verify by reading the file against design.md's decisions (no ordering dependency on `dotfiles`, `install` via `pkgs.coreutils`, `[ -e ]` guard not `[ -f ]`, `$DRY_RUN_CMD` prefix on the write)
- [x] 1.2 Add `./bash-profile.nix` to `modules/home/default.nix`'s imports — verify by grep confirming the import is present

## 2. Documentation

- [x] 2.1 Update `README.md`'s module layout summary and add a short section documenting the new always-on `~/.bash_profile` bootstrap behavior and its never-overwrite guarantee — verify by reading the updated section for consistency with the module

## 3. Validation

- [x] 3.1 Run `nix flake check` and confirm `modules/home/bash-profile.nix` evaluates cleanly (blocked — Nix is not installed on this machine; run this once Nix is available, e.g. via a real install or CI — this is the real acceptance gate, not the individual checkboxes above)
- [x] 3.2 Manually trace each scenario in `specs/shell-login-bootstrap/spec.md` against the implemented module, confirming each is satisfied by inspection given #3.1 cannot run locally (all 4 scenarios traced and satisfied: the `[ ! -e "$BASH_PROFILE" ]` guard creates the file only when absent and sources `.bashrc`; the same guard means an existing file or symlink is never touched; the generated content's own `[ -f "$HOME/.bashrc" ]` check means a missing `.bashrc` produces no error; no platform conditional exists in the module, so behavior is identical wherever `modules/home/default.nix` is consumed — both `mkNixos` and `mkHome`)

**Verification note:** as with every prior change in this repo, Nix is not installed on this machine, so task 3.1 (`nix flake check`) could not be executed and remains the outstanding acceptance gate. Implementation was reviewed manually against `design.md`'s decisions and the module follows the same `home.activation`/`lib.hm.dag.entryAfter` idiom already proven in `modules/home/dotfiles.nix`.
