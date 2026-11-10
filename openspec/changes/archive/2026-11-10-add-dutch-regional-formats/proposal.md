# Proposal

## Why

Tom uses the system in English and reads English weekday and month names fine, but wants numbers, dates, times, currency and paper size shown in European/Dutch conventions. Today `modules/nixos/common.nix` sets only `i18n.defaultLocale = "en_US.UTF-8"`, so everything follows US formatting (`1,234.56`, `MM/DD/YYYY`, 12-hour clock, Letter paper, Sunday as first day of week).

## What Changes

- Keep `LANG` at `en_US.UTF-8` so the interface language and messages stay English.
- Set `LC_NUMERIC`, `LC_MONETARY`, `LC_PAPER`, `LC_MEASUREMENT` to `nl_NL.UTF-8` and `LC_TIME` to `en_DK.UTF-8` via `i18n.extraLocaleSettings` in `modules/nixos/common.nix`, so every NixOS host gets them. `en_DK` is used for time because `nl_NL` would also make weekday and month names Dutch, and glibc has no English-names/Dutch-dates locale (`en_NL`). `en_DK` gives English names, 24-hour clock, Monday-first weeks and ISO dates (`2026-11-10`).
- Add a new `regional-formats` capability describing this behavior.
- **BREAKING**: none. Date, number and currency formatting visibly changes for locale-aware programs.

## Capabilities

### New Capabilities
- `regional-formats`: the system language stays English while number, date/time, currency, paper and measurement formats follow European/Dutch conventions.

### Modified Capabilities
(none)

## Impact

- **Affected code**: `modules/nixos/common.nix` only.
- **Not affected**: `modules/home/*`, `users/*`, `lib/*`, `flake.nix`, `hosts/*`. The existing `lib.mkDefault` on `defaultLocale` is kept, so a host can still override it.
- **Assumptions**:
  - Scope is NixOS hosts. Standalone home-manager machines (non-NixOS Linux, macOS) manage their locale outside this flake and are left alone.
  - `LC_COLLATE` (sort order) and `LC_CTYPE` stay on the English locale, to avoid changing `ls`/`sort` ordering and character handling.
  - GNOME picks up the formats from the system locale. If the Region setting in GNOME Settings was changed by hand, it overrides this.
  - Dates render ISO-style (`2026-11-10`), not Dutch `10-11-26`; this is the closest available glibc locale that keeps English names.
  - `nl_NL.UTF-8` and `en_DK.UTF-8` are generated automatically because NixOS adds every locale named in `extraLocaleSettings` to `i18n.supportedLocales`.

## Non-goals

- Translating the interface or messages to Dutch.
- Changing the keyboard layout or timezone (the latter is handled by `automatic-timezone`).
- Configuring locale on standalone home-manager machines.
