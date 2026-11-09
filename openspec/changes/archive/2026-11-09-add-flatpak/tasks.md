# Tasks

## 1. NixOS module

- [x] 1.1 In `modules/nixos/common.nix`, set `services.flatpak.enable = true;` and add the `flatpak-repo` one-shot systemd service (`RemainAfterExit`, `after`/`wants` `network-online.target`, `path = [ pkgs.flatpak ]`, script `flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo`); verify `nix eval '.#nixosConfigurations.toms-thinkpad.config.services.flatpak.enable'` prints `true` and `...config.systemd.services.flatpak-repo.script` contains the remote-add command
- [x] 1.2 Verify the host still builds: `nix build '.#nixosConfigurations.toms-thinkpad.config.system.build.toplevel' --no-link` succeeds

## 2. Docs

- [x] 2.1 Add a short Flatpak section to `README.md` (install, run, update commands; note apps live outside the Nix store); verify the commands match the configured remote name `flathub`

## 3. Integration

- [x] 3.1 Run `nix fmt` and `nix flake check`; verify both pass and `git status` shows only intended files
- [x] 3.2 After `nixos-rebuild switch` on the host, verify `flatpak remotes` lists `flathub` and `flatpak install flathub org.gnome.Calculator` succeeds (needs network)

## Workflow follow-up

- Archive the change after review with `/opsx:archive`.
