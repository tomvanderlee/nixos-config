# nix-config

A single Nix flake for provisioning both NixOS hosts and non-NixOS systems (any Linux now; macOS via nix-darwin later) from one shared set of modules.

## Layout

- `flake.nix` — inputs (`nixpkgs`, `home-manager`) and outputs (`nixosConfigurations`, `homeConfigurations`, `formatter`, `devShells`)
- `lib/` — `mkNixos` and `mkHome` helper functions that build `nixosConfigurations` / `homeConfigurations` entries
- `modules/nixos/common.nix` — shared NixOS-only system settings applied to every NixOS host
- `modules/home/` — the shared, cross-platform home-manager profile (shell, git, editor, CLI tools). The same modules are consumed whether activated via a NixOS host's home-manager module or standalone `home-manager switch`
- `users/tom.nix` — identity/profile file consumed by both `mkNixos` and `mkHome`
- `hosts/template/` — a copy-source-only NixOS host skeleton; **never** wired into `flake.nix` outputs directly (excluded from discovery by name — see below). Copy it via `scripts/bootstrap-host.sh` (or `nix run .#bootstrap-host`) when provisioning a real machine
- `scripts/bootstrap-host.sh` — scaffolds a new `hosts/<hostname>/` from the template; exposed as `apps.<system>.bootstrap-host`

Any directory under `hosts/` other than `hosts/template` that contains a `system` file automatically becomes a real `nixosConfigurations.<name>` output — adding a host means dropping in a directory, not editing `flake.nix`.

## Installing NixOS on a new machine

This flake does not partition disks for you — do that first, with the standard NixOS installer or manually.

1. Partition and format disks; mount the target filesystems under `/mnt` (including `/mnt/boot` for the ESP if UEFI).
2. Get this repo onto the installer: `nix-shell -p git && git clone <your-remote-url> ~/nix-config` (requires the repo already pushed to a remote — see Follow-ups below).
3. From `~/nix-config`, scaffold the host:
   ```
   nix run .#bootstrap-host -- <real-hostname> --root /mnt --state-version <ver>
   ```
   `--root /mnt` tells the script to read (or generate, via `nixos-generate-config --root /mnt` if needed) `hardware-configuration.nix` from the freshly mounted install target — it never reads the live installer's own `/etc/nixos`, since `--root` has no default and must always be given explicitly. `--state-version` should match the installer's NixOS release (e.g. `24.05`) and should never be changed after the fact.
4. Review `hosts/<real-hostname>/configuration.nix` (boot loader choice, etc.) — the script prints this reminder along with the exact next commands.
5. `cd ~/nix-config && git add hosts/<real-hostname>` (flakes only see git-tracked files).
6. If needed: `export NIX_CONFIG="experimental-features = nix-command flakes"`.
7. `nixos-install --root /mnt --flake ~/nix-config#<real-hostname>`.
8. Reboot and remove the install media.
9. Afterwards, clone the flake to a stable path (e.g. `/etc/nix-config`) so future updates are just `sudo nixos-rebuild switch --flake /etc/nix-config#<real-hostname>`.

## Installing on a non-NixOS system (any Linux, or macOS once supported)

Non-NixOS hosts are unaffected by `bootstrap-host` — there's nothing per-host to scaffold, since `homeConfigurations."tom@linux"` is one generic entry shared by every standalone machine.

1. Install Nix. Recommended: the [Determinate Systems installer](https://github.com/DeterminateSystems/nix-installer) (flakes enabled by default). The official installer also works, but you'll need to add `experimental-features = nix-command flakes` to `nix.conf` yourself.
2. `git clone <your-remote-url> ~/nix-config`.
3. First run: `nix run home-manager/master -- switch --flake ~/nix-config#tom@linux`. After that, `home-manager switch --flake ~/nix-config#tom@linux` works directly.

This only touches your home directory — no sudo required.

## Development

- `nix fmt` — format all `.nix` files with `nixfmt-rfc-style`.
- `nix develop` — a shell with `statix` and `deadnix` for linting.
- `nix flake check` — validates `homeConfigurations."tom@linux"`, `apps.bootstrap-host`, and the other outputs defined here (there are no real `nixosConfigurations` until a host is scaffolded — see Follow-ups).

## Follow-ups (not covered by this change)

- Push this repo to a remote — required before `nixos-install` can `git clone` it during a real install.
- Add a real NixOS host once hardware has been partitioned (see workflow above).
- Add nix-darwin once a real Mac host is being configured.
- Add secrets management (e.g. sops-nix) — none is set up yet.
