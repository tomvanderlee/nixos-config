# Tasks

## 1. LibrePods package

- [x] 1.1 Add `pkgs.librepods` to `linuxOnlyApps` in `modules/home/desktop-apps.nix` (list form, alongside teams-for-linux) and verify `nix eval '.#homeConfigurations."tom@linux".config.home.packages' --apply 'ps: builtins.any (p: (p.pname or "") == "librepods") ps'` prints `true`, and that `tom@darwin` evaluates without it
- [x] 1.2 Build `.#nixosConfigurations.toms-thinkpad.config.system.build.toplevel` and verify `bin/librepods` and `bin/librepods-ctl` exist in the built home-manager path (or the build otherwise succeeds); run `nixfmt --check modules/home/desktop-apps.nix`

## 2. Bluetooth media buttons

- [x] 2.1 Add `services.pipewire.wireplumber.extraConfig."51-bluez-avrcp"."monitor.bluez.properties"."bluez5.dummy-avrcp-player" = true;` with an explanatory comment inside the `desktop.enable` block of `modules/nixos/desktop.nix`; verify via `nix eval` that the option holds the value on `toms-thinkpad` and that a host with `desktop.enable = false` does not set it, and run `nixfmt --check modules/nixos/desktop.nix`

## 3. Documentation and checks

- [x] 3.1 Add a short "LibrePods" section to `README.md` (what it provides, launch with `librepods` / `librepods-ctl noise:anc`, hearing aid not set up, GNOME tray caveat) and verify the commands match the upstream README
- [x] 3.2 Run `nix flake check` and verify it passes
