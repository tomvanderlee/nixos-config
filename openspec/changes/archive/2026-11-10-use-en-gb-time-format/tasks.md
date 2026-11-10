# Tasks

## 1. Locale

- [x] 1.1 Change `LC_TIME` to `en_GB.UTF-8` in `i18n.extraLocaleSettings` in `modules/nixos/common.nix` and update the explanatory comment; verify `nix eval '.#nixosConfigurations.toms-thinkpad.config.i18n.extraLocaleSettings'` shows `LC_TIME = "en_GB.UTF-8"` and `nixfmt --check` passes
- [x] 1.2 Build the host with `nix build '.#nixosConfigurations.toms-thinkpad.config.system.build.toplevel'` and verify `etc/locale.conf` in the result has `LC_TIME=en_GB.UTF-8` with the four `nl_NL.UTF-8` entries, and `i18n.supportedLocales` includes `en_GB.UTF-8/UTF-8` and `nl_NL.UTF-8/UTF-8`
- [x] 1.3 With the built archive (`LOCALE_ARCHIVE_2_27` pointing at the result's glibc-locales), verify `LC_TIME=en_GB.UTF-8 date +%x` prints a day-first date and `date` shows English names
- [x] 1.4 Run `nix flake check`; verify it passes

## Workflow follow-up

- After the switch and a reboot, optionally clear the GNOME Region override (`dconf reset /system/locale/region`) so GNOME apps follow the system locale.
