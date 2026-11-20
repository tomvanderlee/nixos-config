## ADDED Requirements

### Requirement: A .NET host for Mason dotnet-launched packages is provisioned
The shared home-manager profile SHALL provide the .NET SDK, including the `dotnet` command, on `PATH` on every platform where nixpkgs supports it, in a major version able to run the current Bicep language server, so that `mason.nvim` packages launched through `dotnet` (for example the Bicep language server `bicep-lsp`) start successfully.

#### Scenario: Bicep language server starts
- **WHEN** the shared home profile is activated on a supported platform and Neovim starts the Mason-installed `bicep-lsp`
- **THEN** `dotnet` is found on `PATH` and the server process starts without a "dotnet: command not found" or missing-runtime error

#### Scenario: Unsupported platform is not broken
- **WHEN** the shared home profile is evaluated on a platform for which nixpkgs does not provide the .NET SDK
- **THEN** evaluation succeeds and the SDK is simply absent from the package set
