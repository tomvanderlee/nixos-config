# Design

## Context

See proposal.md - Why and Impact. `modules/home/editor.nix` already lists Mason's runtime dependencies (`nodejs`, `python3`, `unzip`) in `home.packages`, with a comment naming Mason as the reason. `CLAUDE.md` prescribes `lib.meta.availableOn pkgs.stdenv.hostPlatform` filtering for packages that may not exist on every platform, as in `modules/home/desktop-apps.nix`.

## Goals / Non-Goals

**Goals:**
- `dotnet` on `PATH` for the Bicep language server, on NixOS, other Linux and macOS.

**Non-Goals:**
- See proposal.md Non-goals.

## Decisions

1. **`dotnet-sdk_10`, not the default `dotnet-sdk` (8.0.x) and not a combined set.** `Bicep.LangServer` targets `net10.0` on `main`, and the default SDK ships only the 8.0 runtime, which cannot load it. A combined 8+9+10 set would add much closure size for a hypothetical need. If the pinned Mason version targets a different major version, change this one package name.
2. **SDK rather than runtime-only.** The runtime-only packages (`dotnet-runtime_10`) would be enough to launch the server, but `dotnet` as a general tool (building, `dotnet tool`) is what "add dotnet" usually means, and the SDK contains the runtime. The cost is the larger closure.
3. **Place it in `editor.nix`, not `languages.nix`.** The need is Mason's dotnet-launched server, matching where `nodejs` and `python3` live, and the `editor-toolchain` capability that already owns those requirements. `languages.nix` is for user-facing Go/Rust toolchains.
4. **Filter with `lib.meta.availableOn`.** nixpkgs' `dotnet-sdk_10` lacks `x86_64-darwin`. The filter makes that platform drop the package silently instead of failing evaluation of the shared profile, consistent with `desktop-apps.nix`. This needs `lib` added to the module's arguments.
5. **No `nix-ld` or env changes.** The nixpkgs `dotnet` binaries are Nix-built wrappers. Mason installs only the managed `Bicep.LangServer.dll`, which the host runs, so no foreign native loader is needed.

## Risks / Trade-offs

- [Mason's pinned `bicep-lsp` (v0.49.2) may target a different .NET major than `main`] → The TFM at that tag was not verified. The apply phase checks by launching the server; if it fails with a missing-runtime message, swap or add the matching SDK package.
- [Closure size grows by a few hundred MB on every machine] → Accepted; matches the user's request for dotnet.
- [`dotnet` first-run telemetry/welcome output] → Not configured here; out of scope.
