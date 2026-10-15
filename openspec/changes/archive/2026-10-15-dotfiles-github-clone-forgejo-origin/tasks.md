## 1. Module option and clone logic

- [x] 1.1 Add `home.dotfiles.originUrl` option (str, default `""`) to `modules/home/dotfiles.nix`. Verify: `nix eval '.#homeConfigurations."tom@linux".config.home.dotfiles.originUrl'` prints the configured value after task 2.1.
- [x] 1.2 In the activation script's missing-checkout branch, when `originUrl` is non-empty, clone with `--origin github` and then `git -C "$DOTFILES_DIR" remote add origin <originUrl>` then set `branch.<current>.remote=origin` and `branch.<current>.merge=refs/heads/<current>` (all via `$DRY_RUN_CMD`; skip the add when the checkout does not exist). When empty, keep the current clone command. Verify: `nix build '.#homeConfigurations."tom@linux".activationPackage'` succeeds and the generated activation script contains the expected commands.
- [x] 1.3 Verify in a scratch `HOME` (temporary dir, local bare repos standing in for the URLs) that a fresh run yields remotes `github` and `origin` with the right URLs and the branch upstream is `origin`, and that a second run leaves an existing checkout's remotes unchanged. Verify: `git -C <tmp>/dotfiles remote -v`.

## 2. User configuration

- [x] 2.1 In `users/tom.nix` set `home.dotfiles.repoUrl = "https://github.com/tomvanderlee/dotfiles.git"` and `home.dotfiles.originUrl = "ssh+git://git@forgejo.lan.tomvanderlee.com:2222/tom/dotfiles.git"`. Verify: `nix flake check` and `nix fmt` pass; `nix eval` shows both values for `tom@linux` and `tom@darwin`.
