# Proposal

## Why

`LC_TIME` is `en_DK.UTF-8`, which keeps English weekday and month names but formats dates as ISO `YYYY-MM-DD` (`2026-11-10`). That is fine for programmers but not what Tom wants for everyday use. glibc has no locale with English names and Dutch `dd-mm-yy` dates (no `en_NL`), and `nl_NL` would bring Dutch names. `en_GB.UTF-8` is the closest fit: English names, 24-hour clock, Monday-first weeks and day-first dates (`10/11/26`, from `d_fmt "%d//%m//%y"`; `date` prints `Tue 10 Nov 2026 ...`), checked in glibc 2.44's locale sources.

## What Changes

- Change `LC_TIME` from `en_DK.UTF-8` to `en_GB.UTF-8` in `i18n.extraLocaleSettings` in `modules/nixos/common.nix`, and update the comment there that explains the choice. The other formats (`LC_NUMERIC`, `LC_MONETARY`, `LC_PAPER`, `LC_MEASUREMENT` = `nl_NL.UTF-8`) and `LANG` stay as they are.
- Modify the `regional-formats` requirement so dates are day-first numeric instead of year-first, and the available-locales scenario lists `en_GB` instead of `en_DK`.
- **BREAKING**: none. Only the date rendering changes (`2026-11-10` to `10/11/26` for locale-aware programs).

## Capabilities

### New Capabilities
(none)

### Modified Capabilities
- `regional-formats`: dates and times use a 24-hour clock with day-before-month numeric dates; `LC_TIME` locale changes.

## Impact

- **Affected code**: `modules/nixos/common.nix` only.
- **Not affected**: `modules/home/*`, `lib/*`, `hosts/*`, flake inputs.
- **Assumptions**:
  - `en_GB` is generated automatically because NixOS adds every locale named in `extraLocaleSettings` to `i18n.supportedLocales`; `en_DK` is dropped from the generated set since nothing references it anymore.
  - The session environment only refreshes after a reboot (or a restart of the user manager), as seen for the previous locale change.
  - GNOME's Region setting (`/system/locale/region`, currently explicitly `en_US.UTF-8`) overrides the system formats for GNOME apps. It is user state and is not changed by this flake; Tom clears it with `dconf reset /system/locale/region` to let GNOME apps follow the system locale. Setting it to `nl_NL` there would instead give Dutch names in GNOME apps.
  - The two-digit year and slash separators (`10/11/26`) are what `en_GB` defines and are accepted; `nl_NL` would give `10-11-26` but Dutch names.

## Non-goals

- Dutch weekday and month names, or a custom locale definition that combines English names with `dd-mm-yyyy`.
- Changing any other locale category, the system language, or the GNOME Region setting.
