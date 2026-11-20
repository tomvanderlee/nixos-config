## ADDED Requirements

### Requirement: The nix-ld library set includes ICU for prebuilt .NET executables
The shared system module SHALL include ICU in `programs.nix-ld.libraries`, so that prebuilt, self-contained .NET executables (for example the Azure-installed Bicep CLI) find the ICU shared libraries they load at startup instead of aborting.

#### Scenario: The nix-ld library directory contains ICU
- **WHEN** a host built from this flake is evaluated
- **THEN** its `programs.nix-ld.libraries` includes ICU, and the built `nix-ld/lib` directory contains `libicuuc.so`

#### Scenario: A prebuilt self-contained .NET executable starts
- **WHEN** a prebuilt, self-contained .NET executable that needs globalization support (for example `~/.azure/bin/bicep --version`) is run on a NixOS host built from this flake
- **THEN** it starts and runs normally instead of aborting with "Couldn't find a valid ICU package installed on the system"
