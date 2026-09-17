## Purpose

Provides a single Nix flake that provisions NixOS hosts from a copyable template and provisions a shared, cross-platform home-manager user profile that installs standalone on non-NixOS systems, keeping both paths built from the same per-user module.

## ADDED Requirements

### Requirement: Host directories are auto-discovered as flake outputs
Any directory under `hosts/` other than `hosts/template` that contains a valid host definition SHALL automatically become a `nixosConfigurations.<name>` output, without requiring any edit to `flake.nix`.

#### Scenario: New host directory becomes buildable without touching flake.nix
- **WHEN** a new directory `hosts/<name>/` is created containing `configuration.nix`, `hardware-configuration.nix`, and a `system` file, and `flake.nix` itself is left unmodified
- **THEN** `nixosConfigurations.<name>` evaluates successfully as part of the flake's outputs

#### Scenario: Template remains excluded from discovery
- **WHEN** the flake's outputs are evaluated
- **THEN** `hosts/template` does not appear as a `nixosConfigurations` entry, regardless of its contents

### Requirement: Host creation is scripted
The system SHALL provide a script that scaffolds a new NixOS host directory from the template, given a hostname, a target root path, and a state version.

#### Scenario: Scaffolding a new host
- **WHEN** the host creation script is run with a hostname, a `--root` path, and a `--state-version`
- **THEN** a `hosts/<hostname>/` directory is created containing a `configuration.nix` with the hostname and state version filled in, a `system` file, and a `hardware-configuration.nix` copied from the given root

#### Scenario: Refusing to overwrite an existing host
- **WHEN** the host creation script is run with a hostname that already has a `hosts/<hostname>/` directory, without an explicit override flag
- **THEN** the script fails without modifying the existing directory

### Requirement: Hardware configuration source is always explicit
The host creation script SHALL require an explicit root path for locating `hardware-configuration.nix` and SHALL NOT read from the invoking system's own `/etc/nixos` unless that path is explicitly given as the root.

#### Scenario: No root provided
- **WHEN** the host creation script is run without a root path specified
- **THEN** the script fails with an error rather than falling back to any default location

#### Scenario: Live installer environment targets the mounted install, not the live system
- **WHEN** the host creation script is run from a NixOS live/installer environment with `--root /mnt` pointing at a freshly mounted install target
- **THEN** the resulting `hardware-configuration.nix` is copied from `/mnt/etc/nixos/hardware-configuration.nix`, and the live environment's own `/etc/nixos/hardware-configuration.nix` is never read

#### Scenario: Hardware configuration cannot be found or generated
- **WHEN** the host creation script is run with a `--root` path that has no `hardware-configuration.nix` and no `nixos-generate-config` command is available to create one
- **THEN** the script fails with a clear error instead of proceeding with a missing or stub file

### Requirement: Install target matches the created host name
The host attribute produced for a newly scaffolded host SHALL exactly match the hostname given to the creation script, so the host can be installed or rebuilt via `<flake>#<hostname>`.

#### Scenario: Installing a newly scaffolded host
- **WHEN** a host is scaffolded with a given hostname
- **THEN** `nixos-install --flake <flake-path>#<hostname>` and `nixos-rebuild switch --flake <flake-path>#<hostname>` both resolve to the configuration that was just scaffolded
