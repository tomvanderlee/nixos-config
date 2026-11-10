# Tasks

## 1. NixOS desktop option

- [x] 1.1 Record the current `.#nixosConfigurations.toms-thinkpad.config.system.build.toplevel.drvPath` for later comparison (`test-vm` no longer exists; `toms-thinkpad` is the desktop host)
- [x] 1.2 Create `modules/nixos/desktop.nix` declaring `desktop.enable` (default `true`) and moving the xserver, GDM, GNOME, dconf dark-mode, PipeWire/rtkit, CUPS, Avahi and Flatpak settings from `modules/nixos/common.nix` under `lib.mkIf`; import it in `lib/mkNixos.nix`; verify the `toms-thinkpad` drvPath is unchanged from 1.1
- [x] 1.3 Evaluate a host with `desktop.enable = false` (via `extendModules`) and verify `services.displayManager.gdm.enable`, `services.pipewire.enable`, `services.printing.enable` and `services.flatpak.enable` are false while `services.openssh.enable` is true
- [x] 1.4 Verify the headless toplevel builds and its closure contains no `gnome-shell` (`nix-store -q --requisites ... | grep gnome-shell` is empty)

## 2. Home profile

- [x] 2.1 Add `home.desktop.enable` (default `osConfig.desktop.enable or true`) to `modules/home/desktop-apps.nix` and gate all GUI apps on it; verify `nix eval '.#homeConfigurations."tom@linux".config.home.packages'` still lists the apps and the same set as before
- [x] 2.2 Verify a headless NixOS host's `home-manager.users.tom.home.packages` contains none of the GUI apps and that setting `home.desktop.enable = false` on a standalone config drops them

## 3. Bootstrap script, template and docs

- [x] 3.1 Add the commented `# desktop.enable = false;` placeholder to `hosts/template/configuration.nix` and the `--headless` flag (usage text included) to `scripts/bootstrap-host.sh`; verify a scaffold with and without the flag in a temp checkout gives the expected `configuration.nix` and that the headless host evaluates
- [x] 3.2 Update `README.md` (shared module description, bootstrap flags, headless VM install flow, Flatpak scope) and `CLAUDE.md`, and verify the documented command works as written

## 4. Integration

- [x] 4.1 Run `nix flake check` and `nixfmt --check` on the changed files; verify both pass and `git status` shows only intended files

## Workflow follow-up

- Archive the change after review with `/opsx:archive`.
