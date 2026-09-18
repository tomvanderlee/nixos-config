## 1. Developer CLI tools

- [x] 1.1 Create `modules/home/dev-tools.nix` with `home.packages = with pkgs; [ gh tmux htop yq-go tree-sitter docker docker-compose kubectl awscli2 ];` — verify by reading the package list against design.md's decisions (especially `yq-go` not `yq`) (note: `terraform` omitted per task 1.3's outcome, see below)
- [x] 1.2 Add `./dev-tools.nix` to `modules/home/default.nix`'s imports — verify by grep confirming the import is present
- [x] 1.3 Check whether `terraform` evaluates cleanly under this flake's `nixpkgs` pin, or requires `nixpkgs.config.allowUnfree = true` / substitution with `opentofu` — verify by consulting nixpkgs' current licensing status for `terraform` (blocked on local verification since Nix isn't installed; record the finding or the substitution decision in this task's notes once checked) (resolved via web research, not local build: confirmed via [NixOS/nixpkgs#253470](https://github.com/NixOS/nixpkgs/issues/253470) that terraform ≥1.6.0 is unfree/BSL-licensed and requires `nixpkgs.config.allowUnfree = true`. Presented this finding plus three options — allow unfree flake-wide, substitute opentofu, or drop terraform — to the user; they chose to drop it. `terraform` is not in the final package list.)

## 2. Shell and prompt

- [x] 2.1 Rewrite `modules/home/shell.nix` to remove `programs.zsh`, `programs.starship`, and `programs.direnv` entirely, replacing its contents with `home.packages = [ pkgs.liquidprompt ];` — verify by reading the file and confirming none of the three removed program blocks remain
- [x] 2.2 Confirm no other file in `modules/home/` re-enables `programs.zsh`, `programs.starship`, or `programs.direnv` — verify by grepping `modules/home/` for each (grep across all of `modules/home/` found zero matches for any of the three)

## 3. NixOS common module: shell, sshd, firewall

- [x] 3.1 In `modules/nixos/common.nix`, change `users.users.tom.shell` from `pkgs.zsh` to `pkgs.bash`, and remove the `programs.zsh.enable = true;` line — verify by reading the file
- [x] 3.2 Add `services.openssh = { enable = true; settings = { PasswordAuthentication = false; PermitRootLogin = "no"; }; };` — verify by reading the added block
- [x] 3.3 Add `networking.firewall = { enable = true; allowedTCPPorts = [ 22 ]; };` — verify by reading the added block

## 4. Documentation

- [x] 4.1 Update `README.md` to document the new `modules/home/dev-tools.nix` packages, the "CLI-only, not the runtime" caveat for docker/kubectl/awscli/terraform, the bash-primary shell switch (including the sshd/firewall additions for future NixOS hosts), and that liquidprompt's configuration is entirely dotfiles-owned — verify by reading the updated sections for consistency with the actual module changes (also updated the layout bullet for `modules/nixos/common.nix` and the dotfiles-precedent note to mention bash/.bashrc alongside git/.gitconfig, and added an explicit note on why terraform was dropped)

## 5. Validation

- [x] 5.1 Run `nix flake check` and confirm the updated `modules/home` and `modules/nixos/common.nix` evaluate without error, including resolving the `terraform` question from task 1.3 (blocked — Nix is not installed on this machine; run this once Nix is available, e.g. via a real install or CI — this is the real acceptance gate, not the individual checkboxes above) (run by the user on a Linux machine with Nix, 2026-09-18: passed with no errors, confirming `yq-go`, `awscli2`, `tree-sitter`, `docker`, `docker-compose`, `kubectl`, `gh`, `tmux`, `htop`, and `liquidprompt` all resolve correctly in nixpkgs)
- [x] 5.2 Manually trace through each spec scenario in `specs/developer-environment/spec.md` against the implemented modules, confirming each is satisfied by inspection given #5.1 cannot run locally (all 4 scenarios traced and satisfied: `dev-tools.nix` flows through the same shared `modules/home` path consumed by both `mkNixos` and `mkHome`; grep confirms no `virtualisation`/daemon config was added anywhere; `shell.nix` is package-only for liquidprompt with no competing managed config; `services.openssh` + `networking.firewall` in `common.nix` match the SSH scenario exactly)

---

**Verification note:** as with every prior change, Nix is not installed on this machine, so task 5.1 (`nix flake check`) could not be executed and remains the outstanding acceptance gate — now shared across four changes in this repo. Package-name correctness (`yq-go`, `awscli2`, `tree-sitter`, `docker`, `docker-compose`, `kubectl`, `gh`, `tmux`, `htop`, `liquidprompt`) was reviewed manually but not verified against a real nixpkgs evaluation.
