## Context

See `proposal.md` - Why for motivation. Relevant constraints verified against this flake's pinned nixpkgs (`nixos-unstable`, rev `b1b875982b17dabde9b4a37f3e229e74913e6db3`), `nixos/modules/programs/nix-ld.nix`:

- The module's real option surface is `programs.nix-ld.enable` (bool), `programs.nix-ld.package`, and `programs.nix-ld.libraries` (`listOf package`).
- `programs.nix-ld.libraries` is a list-typed option, so NixOS's module system merges every module's contribution by concatenation rather than override.
- Once `enable`d, the module's own `config` block (not its `default`) unconditionally sets `programs.nix-ld.libraries` to a baseline set: `zlib zstd stdenv.cc.cc curl openssl attr libssh bzip2 libxml2 acl libsodium util-linux xz systemd`. This baseline always applies — it is not something a consuming module can accidentally clobber by also setting the option.
- `modules/nixos/common.nix` currently has no `lib.mkIf`/feature-flag pattern anywhere; every service (SSH, GNOME, Docker, PipeWire, printing) is turned on unconditionally for every host, with `lib.mkDefault` used only for the two settings (`time.timeZone`, `i18n.defaultLocale`) that a per-host `configuration.nix` is expected to override.
- Only one real host exists today (`hosts/test-vm/`), and neither it nor `hosts/template/` sets any GPU/CUDA-related packages that would need to be folded into a `nix-ld` library list.
- `programs.nix-ld` has no equivalent in home-manager and is not read by `modules/home/*`; it is purely a NixOS system module concern, so it cannot affect the standalone `homeConfigurations` built via `mkHome`.

## Goals / Non-Goals

**Goals:**
- `uv`-fetched prebuilt CPython interpreters and native wheel extensions run correctly on every NixOS host built from this flake, today and for hosts added later.
- The library list is easy to extend later without restructuring anything, since new uv-fetched binaries may need libraries not anticipated now.

**Non-Goals:**
- A full FHS-compatible environment (`buildFHSEnv`/`buildFHSUserEnv`) — `nix-ld` alone is sufficient for the driving use case (running foreign dynamically-linked binaries), and an FHS wrapper is a much larger, unrelated commitment.
- GPU/CUDA-specific libraries — no host in this flake currently has a GPU driver or CUDA toolkit configured, so there is nothing host-specific to add yet.
- A per-host opt-out or feature flag for `nix-ld` — only one real host exists, and `modules/nixos/common.nix` doesn't use feature flags for any of its other unconditional services; a future host that genuinely needs to opt out can still override with `lib.mkForce false` without requiring this design to add a flag preemptively.

## Decisions

**Enable `programs.nix-ld.enable` unconditionally in `modules/nixos/common.nix`, not per-host.**
Matches this file's existing style — every other service (Docker, GNOME, SSH) is unconditional, with `mkDefault` reserved specifically for settings a host is expected to override (locale/timezone). `nix-ld` has no such per-host variance today. Alternative considered: gate it behind a new `home-manager`-style option so hosts could opt in/out — rejected as unnecessary complexity with no current use case, and inconsistent with how every other service in this file is already handled.

**Extend `programs.nix-ld.libraries` with a curated Python-native-extension list, rather than leaving it at nix-ld's own defaults.**
nix-ld's built-in baseline (`zlib`, `openssl`, `bzip2`, `libxml2`, `xz`, `stdenv.cc.cc`, etc.) covers a lot, but common CPython build dependencies it does *not* include are `ncurses`, `libffi`, `sqlite`, `readline`, `gdbm`, and `expat` — all commonly required by python-build-standalone interpreters and native extension wheels. Because the option merges additively, `common.nix` only needs to state the delta, not restate nix-ld's own defaults. Alternative considered: leave `programs.nix-ld.libraries` unset and rely solely on nix-ld's own baseline — rejected because it would likely leave real CPython interpreter/extension failures unresolved, defeating the purpose of this change.

**Keep the library list inline in `modules/nixos/common.nix` rather than a separate `lib/nix-ld-libraries.nix` file.**
The list is short (six packages) and consumed in exactly one place, unlike `lib/unfree-allowlist.nix`, which is imported by both `mkNixos` and `mkHome`. Alternative considered: mirror the `lib/unfree-allowlist.nix` pattern with a dedicated file — rejected as premature indirection for a list this size with a single consumer; can be extracted later if it grows or gains a second consumer.

## Risks / Trade-offs

- **[Risk]** The curated library list is best-effort and may not cover every binary `uv` ever fetches, so some future interpreter or native extension could still fail to load a shared library. → **Mitigation**: `programs.nix-ld.libraries` merges additively (confirmed from the module source), so closing a future gap is a one-line addition to the existing list, not a restructuring.
- **[Risk]** This change cannot be fully verified from this development environment — confirming a `uv`-managed interpreter or native extension actually runs requires an activated NixOS host (`nixos-rebuild switch`), not just a successful build. → **Mitigation**: verification here is limited to `nix flake check` and building the `test-vm` system closure; end-to-end confirmation is called out as a manual follow-up in `tasks.md` rather than claimed as done.
