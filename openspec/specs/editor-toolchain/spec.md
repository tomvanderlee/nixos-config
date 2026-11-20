# editor-toolchain Specification

## Purpose

Provisions, via the shared home-manager profile, the runtime toolchain that the
externally Stow-managed Neovim/mason.nvim config depends on to install and run LSP
servers, formatters, and debug adapters — without home-manager owning that editor
config itself.

## Requirements

### Requirement: mason.nvim installer dependencies are provisioned
The shared home-manager profile SHALL include a Node.js runtime (providing `npm`), a
Python 3 interpreter (providing `python3`), and `unzip` on `PATH`, so that
`mason.nvim`'s package installers can locate the tools they shell out to.

#### Scenario: npm-based Mason package installs successfully
- **WHEN** the shared home profile is activated and `mason.nvim` installs an
  npm-based package (for example an LSP server distributed via npm)
- **THEN** `mason.nvim`'s installer finds `npm` on `PATH` and the installation does
  not fail with an `ENOENT`/"could not find executable" error for `npm`

#### Scenario: Python-based Mason package installs successfully
- **WHEN** the shared home profile is activated and `mason.nvim` installs a
  Python-based package (for example `debugpy`)
- **THEN** `mason.nvim`'s installer finds a `python3` interpreter on `PATH` and the
  installation does not fail with a "no python3 installation found" error

#### Scenario: Archive-based Mason package installs successfully
- **WHEN** the shared home profile is activated and `mason.nvim` installs a package
  distributed as a zip archive (for example `terraform-ls`)
- **THEN** `mason.nvim`'s installer finds `unzip` on `PATH` and the installation does
  not fail with an `ENOENT`/"could not find executable" error for `unzip`

### Requirement: A .NET host for Mason dotnet-launched packages is provisioned
The shared home-manager profile SHALL provide the .NET SDK, including the `dotnet` command, on `PATH` on every platform where nixpkgs supports it, in a major version able to run the current Bicep language server, so that `mason.nvim` packages launched through `dotnet` (for example the Bicep language server `bicep-lsp`) start successfully.

#### Scenario: Bicep language server starts
- **WHEN** the shared home profile is activated on a supported platform and Neovim starts the Mason-installed `bicep-lsp`
- **THEN** `dotnet` is found on `PATH` and the server process starts without a "dotnet: command not found" or missing-runtime error

#### Scenario: Unsupported platform is not broken
- **WHEN** the shared home profile is evaluated on a platform for which nixpkgs does not provide the .NET SDK
- **THEN** evaluation succeeds and the SDK is simply absent from the package set

### Requirement: Editor toolchain packages do not manage editor configuration
Packages provisioned by this capability SHALL supply only the underlying
interpreters/tools that the externally-managed Neovim dotfiles config depends on;
this capability SHALL NOT generate, own, or otherwise manage any Neovim
configuration file (for example `init.lua` or plugin/LSP configuration).

#### Scenario: No competing Neovim configuration is generated
- **WHEN** the shared home profile provisions the editor toolchain packages
- **THEN** no Neovim configuration file is created or managed by this capability —
  the externally Stow-managed dotfiles config remains the sole owner of that
  configuration
