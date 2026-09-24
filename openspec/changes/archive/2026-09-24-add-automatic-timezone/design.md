## Context

See `proposal.md` - Why. Current state: `modules/nixos/common.nix` sets `time.timeZone = lib.mkDefault "Etc/UTC";` and nothing ever updates it. Relevant constraints discovered while investigating the pinned `nixos-unstable` nixpkgs (`nixos/modules/services/system/automatic-timezoned.nix`, `nixos/modules/services/desktops/geoclue2.nix`, `nixos/modules/services/desktop-managers/plasma6.nix`, and `systemd`'s shipped `org.freedesktop.timedate1.policy`):

- `systemd`'s own default polkit policy requires `auth_admin` for `org.freedesktop.timedate1.set-timezone` for any subject, active or not. Nothing in nixpkgs relaxes that for GNOME.
- The KDE Plasma 6 module (`plasma6.nix`) adds its own polkit rule allowing an *active* session to call `set-timezone` without a prompt, backing Plasma's own automatic-timezone UI toggle.
- nixpkgs' GNOME module (`nixos/modules/services/desktops/gnome`) adds no equivalent rule. GNOME Settings' own "Automatic Time Zone" toggle (backed by `gnome-settings-daemon`'s datetime plugin) would therefore hit the default `auth_admin` prompt on this flake's NixOS hosts today - it isn't wired to a passwordless mechanism the way Plasma's is.
- `services.automatic-timezoned` (a small dedicated daemon) is nixpkgs' own DE-agnostic answer to this gap: when enabled it sets `time.timeZone = null;` itself, turns on `services.geoclue2` with its own `appConfig` entry, and ships a polkit rule scoped to its own dedicated `automatic-timezoned` system user - so it runs unattended regardless of desktop environment or which user is logged in.

## Goals / Non-Goals

**Goals:**
- Every NixOS host's `time.timeZone` reflects actual physical location shortly after boot, with no manual step and no interactive authentication.
- The mechanism works the same regardless of which user (if any) is logged into the GNOME session, since it's a system service, not a per-session one.

**Non-Goals:**
- Making GNOME Settings' own "Automatic Time Zone" toggle functional. It's a separate, unwired mechanism on NixOS (see Context) and fixing that is out of scope - `automatic-timezoned` achieves the actual user-visible goal (correct system timezone, which GNOME's clock/calendar read directly from `time.timeZone`/`/etc/localtime`) without it.
- Manual/static location configuration (`services.geoclue2.enableStatic` + `location.latitude`/`longitude`). Network-based geolocation is sufficient for a desktop machine that's expected to have network access shortly after boot.
- Any change to `homeConfigurations` (standalone home-manager, no NixOS layer) - they have no `time.timeZone` to manage.

## Decisions

**Use `services.automatic-timezoned.enable = true;` in `modules/nixos/common.nix`, rather than trying to make GNOME's own toggle work.**

Alternatives considered:
1. **Add a NixOS polkit rule scoped to active GNOME sessions**, mirroring `plasma6.nix`'s `subject.active` rule, then rely on GNOME's own `gsd-datetime` plugin (toggled on via a `dconf` default, the same pattern already used for dark mode in `common.nix`). Rejected: this reverse-engineers and depends on `gsd-datetime`'s internal behavior, which isn't a stable, documented NixOS integration point the way `automatic-timezoned` is: it's exactly the gap `automatic-timezoned` exists to fill for GNOME. It would also only run while a graphical session is active, whereas `automatic-timezoned` is a system service independent of any login.
2. **`services.automatic-timezoned.enable = true;`** (chosen): purpose-built for this exact scenario, self-contained (enables and configures its own `geoclue2` + polkit rule, no manual wiring), maintained in nixpkgs itself, and already proven for the same problem this repo solved for Docker (`container-runtime`) - prefer an existing, documented NixOS module over recreating its internals.

**Leave `time.timeZone = lib.mkDefault "Etc/UTC";` in place rather than removing it.**

`automatic-timezoned`'s module sets `time.timeZone = null;` at normal priority when enabled, which unconditionally overrides the existing `mkDefault`. Leaving the line in place costs nothing and keeps `Etc/UTC` as the documented, explicit fallback if `automatic-timezoned` is ever disabled again on a specific host, without needing to touch `common.nix` a second time.

## Risks / Trade-offs

- **[Risk]** A host with no network access at boot (or geoclue2's beacondb.net lookup failing) never gets a timezone update, and stays on whatever was last applied (or `Etc/UTC` on first boot). → **Mitigation**: none needed for this repo's target hardware (desktops/laptops expected to have network shortly after boot); already called out as a known limitation in `proposal.md`.
- **[Risk]** GNOME's own "Automatic Time Zone" toggle in Settings remains visually present but functionally disconnected from what's actually keeping the timezone correct, which could read as broken/confusing if a user flips it expecting it to be the mechanism. → **Mitigation**: documented as a known limitation in `proposal.md`; the actual observable goal (correct time shown everywhere) is met regardless of that toggle's state, and no further UI work is planned here.
- **[Risk]** A future host that legitimately needs a fixed, non-default timezone must remember to set it at higher-than-default priority (`lib.mkForce` or a plain assignment beats `automatic-timezoned`'s normal-priority `null`, but a naive `lib.mkDefault` override would silently lose to it). → **Mitigation**: called out explicitly in `proposal.md`'s BREAKING/Impact notes; the module's own evaluation-time error (if a plain/default-priority conflicting value is set) makes a silent miss unlikely.

## Migration Plan

Additive, single-file change (`modules/nixos/common.nix`) applied to every NixOS host on next `nixos-rebuild switch` (or equivalent activation). No data migration. Rollback is reverting the one-line addition and rebuilding; `time.timeZone` immediately falls back to the existing `Etc/UTC` default with no other state to clean up (the `automatic-timezoned`/`geoclue` system user and services are removed by NixOS's normal generation switch).
