# Tasks

## 1. Display name and root visibility

- [x] 1.1 Confirm the root cause via `busctl --system get-property org.freedesktop.Accounts /org/freedesktop/Accounts/User0 org.freedesktop.Accounts.User SystemAccount` (false) and `RealName` of User1000 (empty), and record the finding in design.md (the file itself needs interactive sudo)
- [x] 1.2 Add `description = "Tom";` to `users.users.tom` in `modules/nixos/common.nix`; verify `nix eval '.#nixosConfigurations.toms-thinkpad.config.users.users.tom.description'` prints "Tom"
- [x] 1.3 Add the `systemd.tmpfiles` rule that writes `SystemAccount=true` for root to `modules/nixos/desktop.nix` (inside the `desktop.enable` block); verify the rule appears in the desktop host's `systemd.tmpfiles.rules`, is absent with `desktop.enable = false`, and that `systemd-tmpfiles` replaces a stale `SystemAccount=false` file with the new content
- [x] 1.4 Run `nixfmt --check` on the changed files and `nix flake check`; verify both pass and the host toplevel builds

## 2. Documentation

- [x] 2.1 Note the display name and the hidden root account in the "Desktop environment" section of `README.md`; verify the text matches the module behavior

## Workflow follow-up

- After switching, restart `accounts-daemon` (or reboot) and verify the login screen shows "Tom" and no "System administrator" before archiving.
