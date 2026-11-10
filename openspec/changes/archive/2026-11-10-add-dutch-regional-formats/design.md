# Design

## Context

`modules/nixos/common.nix` sets `i18n.defaultLocale = lib.mkDefault "en_US.UTF-8"`. NixOS writes `LANG` and any `LC_*` entries from `i18n.extraLocaleSettings` to `/etc/locale.conf`, and generates every locale named in either option. See proposal.md for motivation.

## Goals / Non-Goals

**Goals:**
- English messages and weekday/month names with Dutch number, currency, paper and measurement formats and European 24-hour dates on all NixOS hosts.

**Non-Goals:**
- Standalone home-manager machines; a Dutch interface language.

## Decisions

- **Use `i18n.extraLocaleSettings` with per-category `LC_*` values, not `LC_ALL` or `defaultLocale = nl_NL`.** `LC_ALL` overrides everything and would force Dutch messages; Dutch `LANG` would translate the interface. Per-category values are exactly "English language, Dutch formats".
- **`LC_TIME = en_DK.UTF-8`, others `nl_NL.UTF-8`.** `LC_NUMERIC`, `LC_MONETARY`, `LC_PAPER`, `LC_MEASUREMENT` use `nl_NL` (comma decimal, euro, A4, metric). `nl_NL` for `LC_TIME` would give Dutch day/month names, which Tom does not want. glibc ships no `en_NL`; `en_DK` (checked in glibc 2.44) has English names, `%T` 24-hour time, `first_weekday` Monday and the same `,`/`.` separators, with ISO dates `%Y-%m-%d`. Alternative: `nl_NL` for `LC_TIME` gives `10-11-26` dates but Dutch names; a custom locale definition would give both but adds maintenance (`i18n.glibcLocales` override) for little gain. `LC_COLLATE` and `LC_CTYPE` are left on `en_US` so sort order and character classes do not change for scripts.
- **Set in `common.nix`, plain values (not `mkDefault`).** The setting is a personal preference shared by all hosts. Per-key `extraLocaleSettings` merge, and a host can still use `lib.mkForce` for a specific category. `defaultLocale` keeps its `mkDefault`.
- **No extra `supportedLocales`.** NixOS adds locales referenced in `extraLocaleSettings` automatically; verify with `locale -a`.
- **Rejected: home-manager `home.language`.** It would also cover standalone machines, but on NixOS it only affects the user session environment, not GDM or system services, and the shared module would need to guard for platform differences. Can be a follow-up.

## Risks / Trade-offs

- [Programs parsing `LC_NUMERIC` output (e.g. `printf '%f'` in bash scripts) may expect a dot] → Only affects locale-aware tools; `LC_ALL=C` restores it per command. Accepted by the user's request.
- [GNOME Region setting may override the system value] → Check in GNOME Settings after switch; clear it if set.
- [Extra locale increases glibc locale archive slightly] → Negligible.

## Migration Plan

`nixos-rebuild switch`, then log out and back in (or reboot) so GDM and the session pick up the new `/etc/locale.conf`. Rollback: revert the commit and switch again.
