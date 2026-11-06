# Tasks

## 1. Host config

- [x] 1.1 Add `services.fprintd.enable = true;` with an enrollment comment to `hosts/toms-thinkpad/configuration.nix`
- [x] 1.2 Verify `nix eval '.#nixosConfigurations.toms-thinkpad.config.services.fprintd.enable'` is `true`

## 2. Checks

- [x] 2.1 Run `nix fmt` and `nix flake check`; verify `git status` shows only intended files

## Runtime follow-up (user, after rebuild)

- Run `lsusb` and `fprintd-enroll`; if no device is found, open a follow-up change for a `services.fprintd.tod` driver.
- Archive the change after review with `/opsx:archive`.
