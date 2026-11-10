# Proposal

## Why

On the GDM login screen the account is listed as `tom` (lowercase) and the `root` account is listed as "System administrator". Cause, confirmed on the running host through AccountsService: user `tom` has an empty full name (`RealName ""`, since `users.users.tom` sets no `description`), so GDM falls back to the login name; and `root` is a cached AccountsService user with `SystemAccount = false` and the GECOS name "System administrator", so GDM offers it as a login choice.

## What Changes

- Set `users.users.tom.description = "Tom"` in `modules/nixos/common.nix` so the login screen shows "Tom".
- Mark the `root` account as a system account for AccountsService so GDM no longer lists it, declared in `modules/nixos/desktop.nix` (it only matters where GDM runs).
- Add requirements to the `gnome-desktop` capability for both behaviors.
- **BREAKING**: none. `root` keeps its password-less locked state; only its visibility in the greeter changes. The login name stays `tom`.

## Capabilities

### New Capabilities
(none)

### Modified Capabilities
- `gnome-desktop`: the login screen lists only real users, by display name.

## Impact

- **Affected code**: `modules/nixos/common.nix` (user description), `modules/nixos/desktop.nix` (hide root).
- **Not affected**: `users/tom.nix`, sshd, sudo, the login name, home directory, and `services.displayManager.hiddenUsers` (that option is only read by SDDM and LightDM, not GDM, so it cannot be used here).
- **Assumptions**:
  - The display name is "Tom" (the capitalized login name), not the full name used in git; easy to change to a full name later.
  - Hiding is done by writing `/var/lib/AccountsService/users/root` with `SystemAccount=true` via `systemd.tmpfiles`; that file is runtime state AccountsService owns, so it is overwritten at each boot/switch rather than left to drift.
  - The greeter updates after a re-login (and AccountsService restart or reboot) because AccountsService caches users.

## Non-goals

- Disabling or removing the root account, or changing how `sudo` works.
- Hiding the user list entirely (`disable-user-list`).
- Setting a full name or avatar for `tom`.
