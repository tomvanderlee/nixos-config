# Design

## Context

nixpkgs lacks `claude-desktop`. Upstream provides only a Debian package (an Electron app, ~630 MB installed, `Depends` on GTK3, NSS, libnotify, libsecret, libgbm, pipewire, xdg-desktop-portal and similar). The shared `modules/home/desktop-apps.nix` already filters a candidate list through `lib.meta.availableOn`, and `lib/unfree-allowlist.nix` gates unfree names. See proposal.md for motivation.

## Goals / Non-Goals

**Goals:**
- Install the official upstream binary reproducibly via the existing home-profile mechanism.
- Work on NixOS (dynamic linking, GNOME portals, keyring) with no FHS tricks visible to the user.

**Non-Goals:**
- Cowork, auto-update, macOS, update automation (see proposal).
- Quick Entry global hotkey: upstream notes it needs the GlobalShortcuts portal on native Wayland; GNOME's portal is already installed, and any gap is upstream's beta limitation.

## Decisions

- **Repackage the official `.deb` in a local derivation** (`pkgs/claude-desktop.nix`, called with `pkgs.callPackage` from `desktop-apps.nix`). `fetchurl` on the pool URL with per-arch SHA-256; unpack with `dpkg-deb -x` (`dpkg` in `nativeBuildInputs`); install under `$out/lib/claude-desktop` and symlink `$out/bin/claude-desktop`; copy the `.desktop` file and icons from the package and rewrite `Exec`/`Icon` to store paths. Alternatives: a community flake (rejected: unofficial, repackages the Windows build); `nix-ld` + dropping the deb contents in place (rejected: not declarative); `apt` in a container (rejected: heavy).
- **Patch with `autoPatchelfHook` and `makeWrapper`**, listing the deb's `Depends` libraries as `buildInputs` (gtk3, nss, libnotify, libsecret, libdrm, mesa/libgbm, at-spi2-core, libxcb, libxtst, libuuid, pipewire, alsa-lib, libappindicator). Wrap with `LD_LIBRARY_PATH` for dlopen'd libs and always pass `--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations` via `--add-flags`, since every host runs GNOME on Wayland; `auto` still falls back to X11 where Wayland is absent. Alternative: `buildFHSEnv` (rejected as the fallback only: bigger closure, breaks sandbox helpers), to be used if autoPatchelf proves insufficient during implementation.
- **Chromium sandbox**: keep the setuid-less path; if `chrome-sandbox` is shipped, do not rely on setuid and let user namespaces handle it (NixOS enables unprivileged user namespaces by default). Verify at launch.
- **Per-arch source table in the derivation** keyed on `stdenv.hostPlatform.system`, with `meta.platforms = [ "x86_64-linux" "aarch64-linux" ]`, `meta.license = lib.licenses.unfree`, `meta.sourceProvenance = [ lib.sourceTypes.binaryNativeCode ]`. That makes the existing `availableOn` filter drop it on darwin and other systems with no extra conditionals.
- **Place it in `crossPlatformApps` unchanged**: `availableOn` already gates by `meta.platforms`, so no new `linuxOnlyApps` entry is needed. Alternative: put it in `linuxOnlyApps` for explicitness; acceptable and equivalent.
- **Pin and bump manually**, documented in README: update `version` and the two hashes from the apt `Packages` index (`Filename`, `SHA256`).

## Risks / Trade-offs

- [Old versions are pruned from the apt pool, so a pinned URL can 404 later] → Accept; the bump procedure is documented, and a built result stays in the Nix store/binary cache until GC.
- [Binary-patching an Electron app misses a dlopen'd library at runtime] → Verify by launching and signing in on the real host; extend `buildInputs`/`LD_LIBRARY_PATH` as needed, fall back to `buildFHSEnv`.
- [Beta software; no in-app updates] → Stated in README; updates arrive only by bumping the pin.
- [Sign-in storage needs a keyring] → GNOME Keyring is part of the GNOME stack on every host; verify credentials persist across restarts.
- [Large download (~180 MB) on each version bump] → Accepted.
