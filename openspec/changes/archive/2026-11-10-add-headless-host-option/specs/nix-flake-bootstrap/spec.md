# Spec Delta

## ADDED Requirements

### Requirement: Host creation can scaffold a headless host
The host creation script SHALL accept an optional `--headless` flag that sets `desktop.enable = false` in the generated `configuration.nix`. Without the flag the generated configuration SHALL NOT disable the desktop.

#### Scenario: Scaffolding a headless host
- **WHEN** the host creation script is run with `--headless`
- **THEN** the generated `hosts/<hostname>/configuration.nix` sets `desktop.enable = false` and the host evaluates as a NixOS configuration

#### Scenario: Default scaffold keeps the desktop
- **WHEN** the host creation script is run without `--headless`
- **THEN** the generated `configuration.nix` does not set `desktop.enable` to `false`
