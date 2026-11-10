# Tasks

## 1. Locale configuration

- [x] 1.1 Add `i18n.extraLocaleSettings` (`LC_NUMERIC`, `LC_MONETARY`, `LC_PAPER`, `LC_MEASUREMENT` = `nl_NL.UTF-8`; `LC_TIME` = `en_DK.UTF-8`) next to `defaultLocale` in `modules/nixos/common.nix`, with a comment explaining English language + Dutch formats; verify with `nix eval '.#nixosConfigurations.<host>.config.i18n.extraLocaleSettings'` on an existing host (or `nix flake check` if none exists)
- [x] 1.2 Run `nix fmt` and verify no diff remains and `nix flake check` passes

## 2. Verification

- [x] 2.1 Build a host with `nix build '.#nixosConfigurations.<host>.config.system.build.toplevel'` and verify `etc/locale.conf` in the result has `LANG=en_US.UTF-8`, `LC_TIME=en_DK.UTF-8` and the four `nl_NL.UTF-8` entries, and that `i18n.supportedLocales` includes `nl_NL.UTF-8/UTF-8` and `en_DK.UTF-8/UTF-8`
- [x] 2.2 After switching on a real host and re-logging in, verify `locale` shows the expected values, `locale -a` lists `nl_NL.utf8` and `en_DK.utf8`, and `date` prints English names with an ISO date and 24-hour time

## Workflow follow-up

- Archive the change after the switch is verified on a real host.
