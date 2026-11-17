# Tasks

## 1. NixOS module

- [x] 1.1 In `modules/nixos/desktop.nix`, inside the `desktop.enable` block, add `programs.kdeconnect = { enable = true; package = pkgs.gnomeExtensions.gsconnect; };`; verify `nix eval '.#nixosConfigurations.toms-thinkpad.config.networking.firewall.allowedTCPPortRanges'` includes 1714-1764 and `config.hardware.uinput.enable` is true
- [x] 1.2 Add `settings."org/gnome/shell".enabled-extensions = [ "gsconnect@andyholmes.github.io" ]` to the existing `programs.dconf.profiles.user.databases` entry (merged with the dark-mode settings); verify the dark-mode default is still present in the evaluated database
- [x] 1.3 Verify a host with `desktop.enable = false` gets no kdeconnect firewall ranges (inspection of the `mkIf` scope, since only `toms-thinkpad` is built)

## 2. Docs

- [x] 2.1 Add a short "Phone integration (KDE Connect)" section to `README.md`: pair from the GNOME top bar menu, enable clipboard sharing, the one-time Extension Manager toggle, and a warning not to install GSConnect from extensions.gnome.org; verify it contains no device IDs or secrets

## 3. Integration

- [x] 3.1 Run `nix fmt -- modules/nixos/desktop.nix`, `nix flake check --no-build` and `nix build '.#nixosConfigurations.toms-thinkpad.config.system.build.toplevel' --no-link`; verify all succeed and `git status` shows only intended files
- [ ] 3.2 After `nixos-rebuild switch` (and removing any extensions.gnome.org copy of GSConnect), pair the phone and verify clipboard sync works in both directions (done by the user)
