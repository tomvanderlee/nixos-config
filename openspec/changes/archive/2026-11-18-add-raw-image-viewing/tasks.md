# Tasks

## 1. Add RawTherapee

- [x] 1.1 Add `pkgs.rawtherapee` to `crossPlatformApps` in `modules/home/desktop-apps.nix`; verify `nix eval '.#homeConfigurations."tom@linux".config.home.packages' --apply 'map (p: p.name)'` lists `rawtherapee` and `tom@darwin` still evaluates
- [x] 1.2 Verify the NixOS home-manager user package list includes `rawtherapee` on `toms-thinkpad`

## 2. Final checks

- [x] 2.1 Run `nix fmt` and `nix flake check`; verify both pass
- [x] 2.2 Run `nix build '.#nixosConfigurations.toms-thinkpad.config.system.build.toplevel'`; verify it succeeds
- [ ] 2.3 After switching, open `~/Downloads/IMG_9250.raw`, `IMG_9251.raw` and `IMG_9252.raw` in RawTherapee; verify each displays
- [x] 2.4 Run `openspec validate add-raw-image-viewing --strict`; verify it passes
