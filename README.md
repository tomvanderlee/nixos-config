# nix-config

A single Nix flake for provisioning both NixOS hosts and non-NixOS systems (any Linux now; macOS via nix-darwin later) from one shared set of modules.

## Layout

- `flake.nix` — inputs (`nixpkgs`, `home-manager`) and outputs (`nixosConfigurations`, `homeConfigurations`, `formatter`, `devShells`)
- `lib/` — `mkNixos` and `mkHome` helper functions that build `nixosConfigurations` / `homeConfigurations` entries
- `modules/nixos/common.nix` — shared NixOS-only system settings applied to every NixOS host
- `modules/home/` — the shared, cross-platform home-manager profile (shell, git, editor, CLI tools). The same modules are consumed whether activated via a NixOS host's home-manager module or standalone `home-manager switch`
- `users/tom.nix` — identity/profile file consumed by both `mkNixos` and `mkHome`
- `hosts/template/` — a copy-source-only NixOS host skeleton; **never** wired into `flake.nix` outputs directly. Copy it to `hosts/<real-hostname>/` when provisioning a real machine

## Installing NixOS on a new machine

This flake does not partition disks for you — do that first, with the standard NixOS installer or manually.

1. Partition and format disks; mount the target filesystems under `/mnt` (including `/mnt/boot` for the ESP if UEFI).
2. Generate hardware config: `nixos-generate-config --root /mnt`. Keep the generated `hardware-configuration.nix`; discard its `configuration.nix`.
3. Get this repo onto the installer: `nix-shell -p git && git clone <your-remote-url> ~/nix-config` (requires the repo already pushed to a remote — see Follow-ups below).
4. Copy the template into a real host: `cp -r ~/nix-config/hosts/template ~/nix-config/hosts/<real-hostname>`.
5. Edit `hosts/<real-hostname>/configuration.nix`: set `networking.hostName`, pick the correct boot loader stanza, set `system.stateVersion` to the installer's NixOS release.
6. Replace the stub hardware config: `cp /mnt/etc/nixos/hardware-configuration.nix ~/nix-config/hosts/<real-hostname>/hardware-configuration.nix`.
7. Add the host to `flake.nix`:
   ```nix
   nixosConfigurations.<real-hostname> = lib.mkNixos {
     hostname = "<real-hostname>";
     system = "x86_64-linux";
   };
   ```
8. `cd ~/nix-config && git add -A` (flakes only see git-tracked files).
9. If needed: `export NIX_CONFIG="experimental-features = nix-command flakes"`.
10. `nixos-install --root /mnt --flake ~/nix-config#<real-hostname>`.
11. Reboot and remove the install media.
12. Afterwards, clone the flake to a stable path (e.g. `/etc/nix-config`) so future updates are just `sudo nixos-rebuild switch --flake /etc/nix-config#<real-hostname>`.

## Installing on a non-NixOS system (any Linux, or macOS once supported)

1. Install Nix. Recommended: the [Determinate Systems installer](https://github.com/DeterminateSystems/nix-installer) (flakes enabled by default). The official installer also works, but you'll need to add `experimental-features = nix-command flakes` to `nix.conf` yourself.
2. `git clone <your-remote-url> ~/nix-config`.
3. First run: `nix run home-manager/master -- switch --flake ~/nix-config#tom@linux`. After that, `home-manager switch --flake ~/nix-config#tom@linux` works directly.

This only touches your home directory — no sudo required.

## Development

- `nix fmt` — format all `.nix` files with `nixfmt-rfc-style`.
- `nix develop` — a shell with `statix` and `deadnix` for linting.
- `nix flake check` — validates `homeConfigurations."tom@linux"` and the other outputs defined here (there are no `nixosConfigurations` yet — see Follow-ups).

## Follow-ups (not covered by this change)

- Push this repo to a remote — required before `nixos-install` can `git clone` it during a real install.
- Add a real NixOS host once hardware has been partitioned (see workflow above).
- Add nix-darwin once a real Mac host is being configured.
- Add secrets management (e.g. sops-nix) — none is set up yet.
