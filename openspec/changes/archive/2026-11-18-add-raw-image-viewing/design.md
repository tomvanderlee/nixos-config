# Design

## Context

GUI apps are provisioned in `modules/home/desktop-apps.nix` (`crossPlatformApps`, filtered by `lib.meta.availableOn`, gated by `home.desktop.enable`). See proposal.md for motivation and evidence.

## Goals / Non-Goals

**Goals:**
- Open the user's Apple ProRAW files in a GUI app with no local compile.

**Non-Goals:**
- Previews in Files or the GNOME image viewer; darktable; upstream fixes.

## Decisions

- **RawTherapee over darktable and glycin's raw loader.** Tested against the real `IMG_9250.raw`: RawTherapee 5.13 exported a 5 MB JPEG; darktable 5.6.2 failed in rawspeed; glycin's libopenraw-based thumbnailer failed with "Operation not supported", also on a copy renamed `.dng`, so the `.raw` extension (mapped to `image/x-panasonic-rw`) is not the cause. glycin's loader would also force a local Rust build of the loaders, Loupe and the thumbnailers.
- **Place it in `crossPlatformApps`.** nixpkgs lists Linux and `aarch64-darwin`; the `availableOn` filter drops it silently elsewhere, and `home.desktop.enable` already gates the list. Alternative: `linuxOnlyApps`; rejected because the package supports darwin.

## Risks / Trade-offs

- [No RAW thumbnails in Files] → accepted; RAW files keep the generic icon.
- [RawTherapee is a heavy editor for just viewing] → accepted; it is the cached tool that decodes the user's files.
- [Other ProRAW files may differ] → only the three sample files are verified.
