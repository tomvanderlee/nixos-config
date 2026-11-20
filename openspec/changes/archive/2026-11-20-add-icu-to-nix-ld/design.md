# Design

## Context

See proposal.md - Why and Impact. `modules/nixos/common.nix` already extends nix-ld's baseline with libraries foreign binaries need (CPython build dependencies, `libstdc++`, `zlib`, and so on), and the `dynamic-linking-support` spec says the set is host-wide and additive.

## Goals / Non-Goals

**Goals:**
- Prebuilt self-contained .NET executables start on every NixOS host.

**Non-Goals:**
- See proposal.md Non-goals.

## Decisions

1. **Add `icu` to `programs.nix-ld.libraries`.** This is the existing mechanism for exactly this class of problem, is one line, is host-wide, and was verified: prepending the `icu` lib directory to `NIX_LD_LIBRARY_PATH` made `~/.azure/bin/bicep --version` succeed. Alternatives: set `DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=1` (hides the error but changes behavior for all .NET programs); install nixpkgs `bicep` (a different binary; the Azure tooling keeps using its own copy); set `LD_LIBRARY_PATH` for the user (leaks Nix libraries into every process).
2. **Comment the package in place.** Put it under its own comment line in the list, like the existing entries, naming .NET as the reason so it is not removed as unused.
3. **Unpinned `icu`.** .NET loads whichever `libicuuc.so.NN` it can find. Pinning would only matter if a future ICU major breaks .NET, which is not the case now.

## Risks / Trade-offs

- [ICU adds tens of MB to every host's closure] → Accepted; the set is intentionally host-wide.
- [A future nixpkgs bump moves `icu` to a major .NET does not yet accept] → Pin `icu` to the previous major in this one line.
- [Fix applies only after `nixos-rebuild switch`, and only to processes started afterwards] → Re-run the failing command in a new shell.

## Migration Plan

Apply with `nixos-rebuild switch`. Rollback: remove the line and switch again.
