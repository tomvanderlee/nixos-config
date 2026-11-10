# Design

## Context

`modules/nixos/common.nix` sets `i18n.extraLocaleSettings` with `LC_TIME = "en_DK.UTF-8"` and the rest `nl_NL.UTF-8` (see the archived `add-dutch-regional-formats`). The comment there says `en_DK` was chosen to keep English names because glibc has no `en_NL`. See proposal.md for why the ISO date is now unwanted.

## Goals / Non-Goals

**Goals:**
- English names, 24-hour clock, Monday-first weeks and day-first numeric dates.

**Non-Goals:**
- A custom locale; Dutch names.

## Decisions

- **`LC_TIME = en_GB.UTF-8`.** glibc 2.44 `en_GB`: `d_fmt "%d//%m//%y"` (slash-separated day/month/year), `t_fmt "%T"` (24-hour), `first_weekday 2` (Monday), English names. `en_IE` is identical in these fields, but `en_GB` is the more common and obvious choice. Alternatives: `nl_NL` (`10-11-26` but Dutch names, rejected earlier), `en_DK` (ISO date, rejected now), a custom `localedef` locale with English names and `%d-%m-%Y` (rejected: needs an `i18n.glibcLocales` override and ongoing maintenance for a cosmetic difference).
- **Only `LC_TIME` changes**, so numbers, currency, paper and units keep their Dutch values and the spec's other scenarios stay valid.
- **No change to GNOME's Region setting**: it is per-user state outside this flake; the proposal documents how it interacts.

## Risks / Trade-offs

- [GNOME apps ignore the new value while Region is `en_US.UTF-8`] → Clear it with `dconf reset /system/locale/region`, or choose a region deliberately.
- [`en_GB` shows a 12-hour clock in some GNOME contexts] → GNOME's clock format is its own setting (`org.gnome.desktop.interface clock-format`); outside this change.
- [Stale user session environment after the switch] → Re-login, or reboot as before.

## Migration Plan

Switch, then reboot (or restart the user manager) so the session picks up `LC_TIME=en_GB.UTF-8`. Rollback: revert the commit and switch again.
