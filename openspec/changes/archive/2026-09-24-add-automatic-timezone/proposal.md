## Why

Every NixOS host built from this flake currently defaults to `Etc/UTC` (`modules/nixos/common.nix`) and nothing ever changes that, so a freshly booted or freshly relocated machine shows the wrong local time/date everywhere (GNOME's clock, calendar, screenshots, log timestamps) until someone manually runs `timedatectl set-timezone`. Tom wants the timezone detected automatically instead.

## What Changes

- Enable `services.automatic-timezoned` unconditionally on every NixOS host, in `modules/nixos/common.nix`, alongside the other unconditional host-level services (GNOME, SSH, printing). This is the NixOS-native daemon for this purpose: it uses `geoclue2` (which it enables and configures itself) to determine location and `systemd-timedated` to actually apply the timezone, and it ships its own polkit rule so the update happens automatically with no interactive auth prompt.
- The existing `time.timeZone = lib.mkDefault "Etc/UTC";` in `modules/nixos/common.nix` is left as-is: `automatic-timezoned` overrides it internally (`time.timeZone = null;`, at normal priority) whenever it's enabled, so `Etc/UTC` only remains as the boot-time value until the daemon determines and applies the real one shortly after boot (network permitting). No host in this repo (checked `hosts/test-vm`, the only real host, and `hosts/template`) sets `time.timeZone` explicitly, so there's no conflict with the module's requirement that an explicit timezone be set with a priority lower than default.
- **Not** relying on GNOME's own Settings → Date & Time → "Automatic Time Zone" toggle: NixOS's `systemd` package ships `org.freedesktop.timedate1.set-timezone` requiring `auth_admin` by default, and unlike the KDE Plasma module (`nixos/modules/services/desktop-managers/plasma6.nix`), nixpkgs' GNOME module adds no polkit rule to relax that for GNOME's own timezone daemon. `automatic-timezoned` ships and enables exactly that rule for its own dedicated service user, so it works without depending on GNOME-side authorization plumbing that isn't wired up on NixOS today. See `design.md` for the alternatives considered here.
- **BREAKING**: none — additive only. A host that later needs a fixed non-`Etc/UTC` timezone can still set `time.timeZone` at a priority higher than default (`lib.mkForce` or a plain assignment) in its own `configuration.nix`; doing so alongside this change without adjusting priority would now raise the same explicit "you set a timezone with `automatic-timezoned` enabled" evaluation error the upstream module already raises by design, which is the intended, deliberate-override behavior — not a silent conflict.

## Capabilities

### New Capabilities
- `automatic-timezone`: every NixOS host built from this flake keeps its system timezone (and therefore the desktop's clock/calendar) in sync with the host's actual location automatically, without manual `timedatectl` intervention or an interactive authorization prompt.

### Modified Capabilities
(none)

## Impact

- **Affected code**: `modules/nixos/common.nix` (add `services.automatic-timezoned.enable = true;`).
- **Not affected**: `modules/home/*` (home-manager-only `homeConfigurations` have no NixOS-level timezone service and are unaffected — they already inherit whatever timezone the host OS provides), `hosts/*/configuration.nix` (no host currently overrides `time.timeZone`), `lib/unfree-allowlist.nix` (`automatic-timezoned` is GPL-3.0, free).
- **Dependencies**: nixpkgs' `automatic-timezoned` and `geoclue2` packages, both already present in the pinned `nixos-unstable` input; no new flake inputs. `geoclue2`'s default network-based location source (`api.beacondb.net`) requires outbound internet access, which this repo's firewall config (inbound-only restrictions) doesn't block.
- **Platforms**: NixOS hosts only (`modules/nixos/common.nix`), via any host built by `lib/mkNixos.nix`. No effect on `homeConfigurations` (`tom@linux`, `tom@darwin`).
- **Known limitation, out of scope**: GNOME's own "Automatic Time Zone" toggle in Settings → Date & Time is not wired to this mechanism and may still prompt for authentication if the user flips it manually; the actual timezone is kept correct by the independent `automatic-timezoned` service regardless of that toggle's state. No reverse-geocoding/location-display UI is added — this only keeps `time.timeZone` current. Timezone detection is network-dependent (Wi-Fi/IP-based geolocation via `geoclue2`); a host with no network at boot keeps whatever timezone was last applied (or `Etc/UTC` on first boot) until connectivity returns.
