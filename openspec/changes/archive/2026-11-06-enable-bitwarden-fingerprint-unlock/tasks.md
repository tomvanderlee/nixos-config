# Tasks

## 1. Host config

- [x] 1.1 In `hosts/toms-thinkpad/configuration.nix`, set `security.polkit.enable = true` and add `pkgs.bitwarden-desktop` to `environment.systemPackages` (add `pkgs` to the module arguments), with a comment explaining the polkit policy lookup
- [x] 1.2 Verify with `nix eval` that `security.polkit.enable` is true, `security.pam.services.polkit-1.fprintAuth` is true, and `environment.systemPackages` contains `bitwarden-desktop`

## 2. Checks

- [x] 2.1 Run `nix fmt` and `nix flake check`; verify `git status` shows only intended files

## Runtime follow-up (user, after rebuild and `fprintd-enroll`)

- Confirm `pkaction --action-id com.bitwarden.Bitwarden.unlock` lists the action.
- In Bitwarden desktop, enable "Unlock with system authentication".
- Archive the change after review with `/opsx:archive`.
