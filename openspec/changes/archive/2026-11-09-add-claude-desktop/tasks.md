# Tasks

## 1. Package

- [x] 1.1 Create `pkgs/claude-desktop.nix`: `fetchurl` of the pinned `4.23118.0` amd64/arm64 `.deb`s from `https://downloads.claude.ai/claude-desktop/apt/stable/pool/main/c/claude-desktop/` with the SHA-256s from the proposal (converted to SRI), unpack with `dpkg-deb -x`, install under `$out/lib/claude-desktop`, link `$out/bin/claude-desktop` (wrapped with `--ozone-platform-hint=auto` for Wayland), install the `.desktop` file and icons with `Exec`/`Icon` rewritten; set `meta` (unfree license, `platforms`, `mainProgram`). Verify `nix build --impure --expr 'with import <nixpkgs> {}; callPackage ./pkgs/claude-desktop.nix {}'` (or via the flake once wired) produces a store path with `bin/claude-desktop` and a `share/applications/*.desktop` file
- [x] 1.2 Add `autoPatchelfHook`, `makeWrapper` and the deb's `Depends` libraries as `buildInputs`; verify `ldd` on the main executable shows no `not found` and `result/bin/claude-desktop --version` (or `--help`) runs without a missing-library error

## 2. Profile wiring

- [x] 2.1 Add `"claude-desktop"` to `lib/unfree-allowlist.nix` and add `(pkgs.callPackage ../../pkgs/claude-desktop.nix { })` to the candidate list in `modules/home/desktop-apps.nix`; verify `nix eval '.#homeConfigurations."tom@linux".config.home.packages' --apply 'ps: map (p: p.name) ps'` lists `claude-desktop-4.23118.0` and the same eval for `"tom@darwin"` does not
- [x] 2.2 Verify the NixOS host builds with the app: `nix build '.#nixosConfigurations.toms-thinkpad.config.system.build.toplevel' --no-link` succeeds

## 3. Docs

- [x] 3.1 Add a "Claude Desktop" section to `README.md` covering beta status, no in-app updates, and the bump procedure (copy `Filename`/`SHA256` for each arch from `https://downloads.claude.ai/claude-desktop/apt/stable/dists/stable/main/binary-<arch>/Packages` into `pkgs/claude-desktop.nix`); verify the documented URL returns the `Packages` index

## 4. Integration

- [x] 4.1 Run `nix fmt` and `nix flake check`; verify both pass and `git status` shows only intended files
- [x] 4.2 After `nixos-rebuild switch` on the host, verify Claude Desktop appears in the GNOME app menu, launches, signs in and keeps the session across a restart (keyring), and that the window renders natively under Wayland (in GNOME Looking Glass, `lg` → Windows, the window is not listed as X11/XWayland)

## Workflow follow-up

- Archive the change after review with `/opsx:archive`.
