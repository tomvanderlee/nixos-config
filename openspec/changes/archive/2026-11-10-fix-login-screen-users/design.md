# Design

## Context

GDM builds its user list from AccountsService. Queried over D-Bus on the running host: `User0` (root) has `SystemAccount=false` and `RealName="System administrator"` (NixOS gives root that GECOS), and `User1000` (tom) has `RealName=""`, so GDM shows the login name. `users.users.tom` in `modules/nixos/common.nix` has no `description`. See proposal.md for motivation.

## Goals / Non-Goals

**Goals:**
- Greeter shows "Tom" and no root entry, declaratively, on every desktop host.

**Non-Goals:**
- Changing root's password state or login capability.

## Decisions

- **`users.users.tom.description = "Tom"`** in `common.nix`. This sets the GECOS field, which AccountsService reads as `RealName`. It applies to all hosts (headless too), which is harmless and keeps the account definition in one place.
- **Hide root with an AccountsService override file via `systemd.tmpfiles.rules`** in `desktop.nix`: `f+ /var/lib/AccountsService/users/root 0600 root root - [User]\nSystemAccount=true`. `f+` replaces any existing file, so a stale `SystemAccount=false` is corrected. Alternatives: `services.displayManager.hiddenUsers` (rejected: only SDDM and LightDM read it; confirmed in nixpkgs), GDM `disable-user-list` dconf key (rejected: hides all users and forces typing the name), changing root's GECOS or shell (rejected: does not set the `SystemAccount` flag and would alter the account).
- **Root cause confirmed over D-Bus, not from the file.** Reading `/var/lib/AccountsService/users/root` needs interactive sudo, which was not available in the apply session. `busctl` on `org.freedesktop.Accounts` already showed `SystemAccount=false` for root and an empty `RealName` for tom, which is what GDM acts on. The `f+` rule writes the file whether or not it exists, so the fix does not depend on its prior state; the final login-screen check after a switch is the real verification.

## Risks / Trade-offs

- [AccountsService rewrites the file and resets the flag] → It only rewrites fields it manages; `f+` reapplies on each boot and switch. Verify after a re-login.
- [AccountsService caches the old name until restarted] → `systemctl restart accounts-daemon` (or reboot) on first application; documented in tasks.
- [Overwriting the file drops other settings in it] → Root has no stored language/icon settings that matter; the file is replaced with only `SystemAccount=true`.

## Migration Plan

Switch, then `sudo systemctl restart accounts-daemon` (or reboot) and look at the login screen. Rollback: revert the commit and switch; delete `/var/lib/AccountsService/users/root` if the hide should be undone immediately.
