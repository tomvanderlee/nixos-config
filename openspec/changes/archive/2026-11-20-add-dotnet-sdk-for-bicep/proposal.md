# Proposal

## Why

Tom is adding Bicep (Azure infrastructure DSL) support to his Neovim config. The Bicep language server is installed by `mason.nvim` as the `bicep-lsp` package and is launched as `dotnet .../Bicep.LangServer.dll`, so a .NET host (`dotnet`) must be on `PATH`. The shared home profile currently provides Node.js, Python 3 and `unzip` for Mason's installers and servers, but no .NET.

## What Changes

- Add the .NET 10 SDK (`pkgs.dotnet-sdk_10`, MIT) to `home.packages` in `modules/home/editor.nix`, next to the other Mason dependencies, filtered through `lib.meta.availableOn pkgs.stdenv.hostPlatform` so a platform without it silently drops it instead of failing evaluation.
- Update the comment above that package list to say .NET is for Mason's dotnet-launched servers.
- **BREAKING**: none.

## Capabilities

### New Capabilities
(none)

### Modified Capabilities
- `editor-toolchain`: the shared profile also provides a .NET host on `PATH` for Mason packages that run on .NET (the Bicep language server).

## Impact

- **Affected code**: `modules/home/editor.nix`.
- **Not affected**: `modules/nixos/*` (no `nix-ld` change; the nixpkgs `dotnet` wrapper is Nix-built and needs no foreign-loader support), `lib/unfree-allowlist.nix` (MIT, free), `flake.nix`, `hosts/*`, and everything under `~/.config/nvim` (owned by the dotfiles repo).
- **Closure size**: the .NET SDK adds a few hundred MB to every machine that activates the profile.
- **Verified facts**: nixpkgs provides `dotnet-sdk_10` 10.0.403, license MIT, platforms `x86_64-linux`, `aarch64-linux`, `aarch64-darwin` (not `x86_64-darwin`). `Azure/bicep` main targets `net10.0` for `Bicep.LangServer` (SDK 10.0.404 in `global.json`). The Mason `bicep-lsp` package pins v0.49.2 and launches `dotnet:extension/bicepLanguageServer/Bicep.LangServer.dll`; its target framework at that exact tag was not checked.
- **Assumptions** (recorded, no clarification needed):
  - .NET 10 is chosen over nixpkgs' default `dotnet-sdk` (8.0.x), which cannot run a `net10.0` assembly. The SDK is chosen over the bare runtime so `dotnet` is also usable for building and for other tools; the SDK includes the runtime.
  - Only the .NET host is provisioned here. The Bicep plugin/LSP configuration and the `bicep-lsp` Mason install live in the dotfiles repo.
  - If Mason later pins a `bicep-lsp` built for a different .NET major version, the package choice here must be revisited.

## Non-goals

- Installing the Bicep CLI or language server through Nix (Mason owns that, to match the other servers).
- Editing the Neovim dotfiles (Bicep filetype, `lspconfig` setup, Mason ensure-installed list).
- `DOTNET_ROOT` or other environment variables; the nixpkgs `dotnet` wrapper finds its own root.
- A dedicated .NET language-toolchain capability (C# language server, NuGet configuration, etc.).
