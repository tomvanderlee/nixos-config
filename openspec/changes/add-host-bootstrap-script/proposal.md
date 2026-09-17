## Why

Adding a real host today is fully manual: copy `hosts/template`, hand-edit `CHANGEME` placeholders, copy `hardware-configuration.nix` from wherever the caller happens to point, and hand-append a `nixosConfigurations.<host>` stanza into `flake.nix`. This is error-prone (nothing stops copying `hardware-configuration.nix` from the wrong place, e.g. a NixOS live ISO's own `/etc/nixos` instead of a freshly mounted install target) and requires editing generated Nix source by hand for every new machine.

## What Changes

- Switch `flake.nix`'s `nixosConfigurations` from a hardcoded empty attrset to auto-discovery: any directory under `hosts/` (other than `hosts/template`) that contains a `system` file becomes a real `nixosConfigurations.<name>` output automatically, with `system` read from that file. **BREAKING**: adding a host no longer requires editing `flake.nix`; the previously-documented manual stanza-append step is removed from the workflow.
- Add `hosts/template/system` (a placeholder system-string file) so the template stays a complete copy-source consistent with real hosts, while remaining excluded from discovery by name.
- Add `scripts/bootstrap-host.sh`, exposed as `apps.<system>.bootstrap-host` in `flake.nix` (via `pkgs.writeShellApplication`), that scaffolds a new host: copies `hosts/template`, fills in hostname/state-version, writes the `system` file, and copies `hardware-configuration.nix` from an explicitly-specified root directory.
- The script always requires an explicit `--root` flag for where to source `hardware-configuration.nix` from (`<root>/etc/nixos/hardware-configuration.nix`) — there is no default and no environment auto-detection, so a run from a NixOS live/installer environment can never accidentally read the live ISO's own `/etc/nixos` instead of the mounted install target.
- Update `README.md`'s NixOS install workflow to use the script instead of the manual copy/edit/flake.nix-edit sequence.
- Non-NixOS (standalone home-manager) hosts are explicitly out of scope for this script: `homeConfigurations."tom@linux"` stays generic, and the existing clone + `home-manager switch` workflow already covers "getting the right files onto a non-NixOS machine" — nothing new is scaffolded there.

## Capabilities

### New Capabilities
- `nix-flake-bootstrap`: extends the existing flake-bootstrap capability (from the still-in-flight `add-nix-flake-bootstrap` change, not yet archived into `openspec/specs/`) with scripted host creation and directory-driven `nixosConfigurations` discovery. Reusing the same capability path rather than introducing a second one, since this is additional behavior of the same "provision hosts from this flake" capability, not a separate concern.

### Modified Capabilities
(none — `nix-flake-bootstrap` does not yet exist under `openspec/specs/`, since the change that introduces it hasn't been archived. This change's delta uses ADDED requirements only, extending rather than altering what that change already proposed.)

## Impact

- Affected code: `flake.nix` (nixosConfigurations discovery + new `apps` output), `scripts/bootstrap-host.sh` (new), `hosts/template/system` (new), `README.md` (install workflow section).
- Depends on the `add-nix-flake-bootstrap` change's files already present in the repo (`hosts/template/`, `lib/mkNixos.nix`) — this change builds directly on that structure.
- No live NixOS host or remote exists yet, so the script's actual `nixos-generate-config`/mount-based behavior can only be verified by careful manual review and (eventually) a real install or CI, not locally — Nix is still not installed on this development machine.
- No system currently depends on the old "hand-edit `flake.nix`" workflow (no real host has been created yet), so the breaking change has no live migration cost.
