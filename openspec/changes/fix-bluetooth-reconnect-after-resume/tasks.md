# Tasks

## 1. Precondition

- [ ] 1.1 After the next failed resume, run `sudo systemctl restart bluetooth` and click the mouse; verify it reconnects (done by the user). If it does not, stop and do not apply the remaining tasks.

## 2. NixOS module

- [ ] 2.1 In `modules/nixos/desktop.nix`, inside the `desktop.enable` block, add `systemd.services.bluetooth-resume-restart` guarded by `lib.mkIf config.hardware.bluetooth.enable`, as a `Type = "oneshot"` unit with `wantedBy` and `after` set to `post-resume.target` and the script `systemctl try-restart bluetooth.service`, with a comment naming it a stopgap for the upstream BlueZ reconnect bug and giving the removal condition; verify `nix eval '.#nixosConfigurations.toms-thinkpad.config.systemd.services.bluetooth-resume-restart.wantedBy'` returns `[ "post-resume.target" ]`
- [ ] 2.2 Verify the unit is absent when the gate is false by inspection of the `mkIf` scope (only `toms-thinkpad` is built, and it has `desktop.enable` and Bluetooth enabled)

## 3. Integration

- [ ] 3.1 Run `nix fmt -- modules/nixos/desktop.nix`, `nix flake check --no-build` and `nix build '.#nixosConfigurations.toms-thinkpad.config.system.build.toplevel' --no-link`; verify all succeed and `git status` shows only intended files
- [ ] 3.2 After `nixos-rebuild switch`, suspend and resume, then verify `systemctl status bluetooth-resume-restart` shows a successful run and the mouse reconnects after clicking it (done by the user); repeat over a few days and note whether it ever fails
