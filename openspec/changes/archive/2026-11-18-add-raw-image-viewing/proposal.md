# Proposal

## Why

Camera RAW photos (the user's are Apple ProRAW DNGs from an iPhone 16 Pro Max, named `.raw`) cannot be opened on the desktop. The GNOME image viewer and GNOME Files decode images through glycin, whose libopenraw-based RAW loader is not enabled in nixpkgs and, when built locally, still fails on ProRAW (linear, lossless-JPEG, 3-channel 10-bit DNG). darktable 5.6.2 also fails on these files (rawspeed: "Unsupported predictor mode: 7"). LibRaw 0.22.3 decodes them, and RawTherapee 5.13, which is binary-cached in nixpkgs, exports a JPEG from them.

## What Changes

- Add RawTherapee to the shared home-manager desktop applications, so RAW photos, including Apple ProRAW, can be opened in a cached application with no local compile.

## Capabilities

### New Capabilities

### Modified Capabilities
- `desktop-applications`: adds a requirement that RawTherapee is provisioned and opens Apple ProRAW DNG files.

## Impact

- `modules/home/desktop-apps.nix` (add `pkgs.rawtherapee` to `crossPlatformApps`).
- RawTherapee is GPL-3.0-or-later, so `lib/unfree-allowlist.nix` is unchanged; nixpkgs lists x86_64-linux, aarch64-linux and aarch64-darwin, and the existing `availableOn` filter handles anything else.
- No services, ports or users are affected; no local compile.

## Non-goals

- RAW previews or thumbnails in GNOME Files and the GNOME image viewer.
- darktable (cannot decode ProRAW).
- Patching or locally rebuilding glycin/libopenraw.
