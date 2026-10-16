# Tasks

## 1. NixOS desktop option

- [ ] 1.1 Record the current `path:/home/tom/desktop-flake#nixosConfigurations.test-vm.config.system.build.toplevel.drvPath` for later comparison
- [ ] 1.2 Create `modules/nixos/desktop.nix` declaring `desktop.enable` (default `true`) and moving the xserver, GDM, GNOME, dconf dark-mode, PipeWire/rtkit, CUPS and Avahi settings from `modules/nixos/common.nix` under `lib.mkIf`; import it in `lib/mkNixos.nix`; verify the `test-vm` drvPath is unchanged from 1.1
- [ ] 1.3 Evaluate a host with `desktop.enable = false` (temporary `extraModules` or a scaffolded host) and verify `services.displayManager.gdm.enable`, `services.pipewire.enable` and `services.printing.enable` are false while `services.openssh.enable` is true
- [ ] 1.4 Verify the headless toplevel builds and its closure contains no `gnome-shell` (`nix-store -q --requisites ... | grep gnome-shell` is empty)

## 2. Home profile

- [ ] 2.1 Add `home.desktop.enable` (default `osConfig.desktop.enable or true`) to `modules/home/desktop-apps.nix` and gate all GUI apps on it; verify `nix eval '.#homeConfigurations."tom@linux".config.home.packages'` still lists the apps and the same set as before
- [ ] 2.2 Verify a headless NixOS host's `home-manager.users.tom.home.packages` contains none of the GUI apps and that setting `home.desktop.enable = false` on a standalone config drops them

## 3. Bootstrap script, template and docs

- [ ] 3.1 Add the commented `# desktop.enable = false;` placeholder to `hosts/template/configuration.nix` and the `--headless` flag (usage text included) to `scripts/bootstrap-host.sh`; verify a scaffold with and without the flag in a temp checkout gives the expected `configuration.nix` and that the headless host evaluates
- [ ] 3.2 Update `README.md` (shared module description, bootstrap flags, headless VM install flow) and verify the documented command works as written

## 4. Integration

- [ ] 4.1 Run `nix fmt` and `nix flake check`; verify both pass and `git status` shows only intended files

## Workflow follow-up

- Archive the change after review with `/opsx:archive`.
