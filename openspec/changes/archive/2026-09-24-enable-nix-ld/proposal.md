## Why

`uv` (provisioned in `modules/home/dev-tools.nix`) doesn't just run Python code — `uv python install` fetches prebuilt CPython interpreters (python-build-standalone), and `uv pip install`/`uv tool install` can pull wheels with prebuilt native (C-extension) binaries. These are ordinary dynamically-linked ELF binaries built against a generic glibc loader path (`/lib64/ld-linux-x86-64.so.2`) that doesn't exist on NixOS, so they fail to execute without `nix-ld`. This was explicitly flagged as a known, deferred gap in the change that added `uv` itself (`openspec/changes/archive/2026-09-24-add-uv-and-docker-runtime/proposal.md`: *"no `nix-ld`/extra container-toolchain packages beyond what's already provisioned"*). This change closes that gap.

## What Changes

- Enable `programs.nix-ld.enable = true;` unconditionally on every NixOS host, in `modules/nixos/common.nix`, alongside the other unconditional host-level services (GNOME, SSH, Docker) — matching that file's existing no-feature-flag style.
- Extend `programs.nix-ld.libraries` with a small curated set of common CPython native-extension dependencies (`ncurses`, `libffi`, `sqlite`, `readline`, `gdbm`, `expat`) that aren't already covered by nix-ld's own built-in baseline list (`zlib`, `zstd`, `stdenv.cc.cc`, `curl`, `openssl`, `attr`, `libssh`, `bzip2`, `libxml2`, `acl`, `libsodium`, `util-linux`, `xz`, `systemd`, confirmed from the pinned nixpkgs module source). `programs.nix-ld.libraries` merges additively across modules, so this only adds to nix-ld's own defaults rather than replacing them.
- **BREAKING**: none — additive only. Only applies to NixOS hosts (`modules/nixos/common.nix`); the standalone `tom@linux`/`tom@darwin` home-manager profiles (`homeConfigurations`, built via `mkHome`) are unaffected, since `programs.nix-ld` is a NixOS-only module option with no equivalent in home-manager.

## Capabilities

### New Capabilities
- `dynamic-linking-support`: NixOS hosts built from this flake can run prebuilt, foreign (non-Nix-built) dynamically-linked binaries — such as the interpreters and native wheel extensions `uv` fetches — via `nix-ld`, rather than failing with a missing-interpreter/exec error.

### Modified Capabilities
- None. `developer-environment` already provisions `uv` itself and makes no claim about dynamic-linking behavior, so its spec is untouched.

## Impact

- **Affected code**: `modules/nixos/common.nix` only (add `programs.nix-ld.enable` and extend `programs.nix-ld.libraries`).
- **Not affected**: `modules/home/*` (including `dev-tools.nix`, which already provisions `uv`), `homeConfigurations`/`lib/mkHome.nix`, `lib/unfree-allowlist.nix` (the `nix-ld` package and all added libraries are free-licensed, no allowlist entry needed), `hosts/template/` and `hosts/test-vm/` (no per-host override needed — this is a shared baseline, same as GNOME/SSH/Docker).
- **Dependencies**: nixpkgs' built-in `nix-ld` NixOS module (`nixos/modules/programs/nix-ld.nix`) and its default `nix-ld` package, both already present in the pinned `nixos-unstable` input; no new flake inputs.
- **Platforms**: NixOS hosts only (`nixosConfigurations`, via `mkNixos`/`modules/nixos/common.nix`). No effect on standalone home-manager-only platforms.
- **Known limitation, out of scope**: the curated library list is best-effort, not exhaustive — some future uv-fetched binary could still need a library not in the list. Because `programs.nix-ld.libraries` merges additively, closing such a gap later is a one-line addition, not a rework.
