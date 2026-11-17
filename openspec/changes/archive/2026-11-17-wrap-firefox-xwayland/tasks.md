# Tasks

## 1. Firefox wrapper

- [x] 1.1 In `modules/home/desktop-apps.nix`, add a `firefox` `symlinkJoin` wrapper (name `firefox-${pkgs.firefox.version}`, `makeWrapper`, `wrapProgram $out/bin/firefox --set MOZ_ENABLE_WAYLAND 0`, `inherit (pkgs.firefox) meta`) next to `nextcloud-client`, with a comment explaining the crash/stall symptoms and how to revert; verify with `nix eval --raw '.#homeConfigurations."tom@linux".pkgs.firefox.version'` style evaluation succeeding
- [x] 1.2 Replace `pkgs.firefox` with the wrapper in `crossPlatformApps`; verify `nix eval '.#homeConfigurations."tom@linux".config.home.packages' --apply 'map (p: p.name)'` lists `firefox-<version>` once
- [x] 1.3 Inspect the built wrapper (`nix build '.#homeConfigurations."tom@linux".activationPackage'`, then `grep MOZ_ENABLE_WAYLAND` in the home-path `bin/firefox` and check the `Exec=` line of `share/applications/firefox.desktop`); also confirm `lib/mozilla/native-messaging-hosts` is present in the output and the outer wrapper does not override `MOZ_SYSTEM_DIR`; verify the variable is set to 0, the inner wrapper is still reached, and the menu entry launches through the wrapper, fixing the desktop file if it does not

## 2. Integration

- [x] 2.1 Run `nix fmt -- modules/home/desktop-apps.nix`, `nix flake check --no-build` and `nix build '.#nixosConfigurations.toms-thinkpad.config.system.build.toplevel' --no-link`; verify all succeed and `git status` shows only intended files
- [ ] 2.2 After `nixos-rebuild switch`, restart Firefox and open `about:support`; verify Window Protocol reads `x11`, from both the application menu and a terminal and, if you use the Bitwarden browser extension with the desktop app, that it still connects (done by the user)

## Workflow follow-up

- Archive the change after the rebuild is verified.
- Open a follow-up change to remove the wrapper once Firefox's Wayland path is fixed.
