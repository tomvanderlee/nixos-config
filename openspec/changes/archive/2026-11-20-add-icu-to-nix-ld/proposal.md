# Proposal

## Why

Running the self-contained Bicep CLI (`~/.azure/bin/bicep`, a prebuilt single-file .NET executable fetched by Azure tooling) on toms-thinkpad aborts with `Couldn't find a valid ICU package installed on the system` and a `System.Environment.FailFast` trace. Self-contained .NET binaries load ICU (`libicuuc.so.NN`) at startup for globalization. The nixpkgs `dotnet` host used by Mason's `bicep-lsp` is wrapped so it finds ICU, which is why the language server works, but a foreign .NET binary is run through `nix-ld`, and `nix-ld`'s library set (`modules/nixos/common.nix`) has no ICU.

Reproduced: `~/.azure/bin/bicep --version` fails as above. With `icu` prepended to `NIX_LD_LIBRARY_PATH` it prints `Bicep CLI version 0.49.2 (b34271ac51)`.

## What Changes

- Append `icu` to `programs.nix-ld.libraries` in `modules/nixos/common.nix`, with a comment saying it is for prebuilt self-contained .NET binaries.
- **BREAKING**: none.

## Capabilities

### New Capabilities
(none)

### Modified Capabilities
- `dynamic-linking-support`: the nix-ld library set also provides ICU, so prebuilt self-contained .NET executables start.

## Impact

- **Affected code**: `modules/nixos/common.nix`.
- **Not affected**: `modules/home/*` (no home-profile change; the `dotnet-sdk_10` from the previous change is unrelated to this failure), `lib/unfree-allowlist.nix`, `flake.nix`, `hosts/*`, standalone home-manager and macOS machines (nix-ld is NixOS-only).
- **Verified facts**: nixpkgs `icu` is 78.3, license Unicode-3.0 (free), supported on x86_64-linux, aarch64-linux and aarch64-darwin. It provides `libicuuc.so.78`. The `/run/current-system/sw/share/nix-ld/lib` directory currently contains no ICU library.
- **Closure size**: ICU adds roughly tens of MB to every NixOS host.
- **Assumptions** (recorded, no clarification needed):
  - The failing binary is `~/.azure/bin/bicep`, installed outside Nix (the `az bicep` flow). Tom keeps using it, so the fix targets the dynamic-linking gap, not replacing it with nixpkgs' `bicep`.
  - The package is `icu` (resolves to the current `icu4c`), not a version-pinned one. .NET probes several ICU major versions, so 78 is accepted; if a future .NET rejects it, pin an older ICU.

## Non-goals

- Switching to nixpkgs' `bicep` package, or removing the Azure-installed binary.
- Setting `DOTNET_SYSTEM_GLOBALIZATION_INVARIANT` globally (it would silently disable culture-aware behavior for every .NET program).
- Changes to the Mason `bicep-lsp` setup, which already works.
- Other native libraries that other foreign .NET binaries might need (OpenSSL and zlib are already in the nix-ld set).
