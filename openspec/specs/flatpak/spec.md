# flatpak Specification

## Purpose
Lets the user install and run applications that are not packaged in nixpkgs, by providing the Flatpak runtime and the Flathub remote on every desktop-enabled NixOS host built from this flake.

## Requirements

### Requirement: Flatpak is available on every NixOS host
Every NixOS host built from this flake's shared system module with the desktop enabled SHALL have the Flatpak service enabled, without per-host opt-in, so the `flatpak` command can install and run applications. A host that sets `desktop.enable = false` SHALL NOT enable Flatpak.

#### Scenario: Flatpak command is available
- **WHEN** a desktop-enabled NixOS host built from this flake's shared system module is evaluated
- **THEN** `services.flatpak.enable` is true

#### Scenario: Headless host has no Flatpak
- **WHEN** a NixOS host built from this flake's shared system module sets `desktop.enable = false`
- **THEN** `services.flatpak.enable` is false and the host still builds

### Requirement: Flathub remote is configured automatically
Each desktop-enabled NixOS host SHALL have the Flathub remote added at system level without manual `flatpak remote-add`. Adding the remote SHALL be idempotent and SHALL NOT fail the system activation or boot when the network is unavailable.

#### Scenario: Install from Flathub right after first boot
- **WHEN** a freshly installed host has booted once with network access
- **THEN** `flatpak remotes` lists `flathub` and `flatpak install flathub <app-id>` works without further setup

#### Scenario: Offline boot
- **WHEN** the host boots without network access
- **THEN** boot and `nixos-rebuild switch` still succeed, and the remote is added on a later boot or switch with network access

#### Scenario: Remote already present
- **WHEN** the host is rebuilt and the `flathub` remote already exists
- **THEN** the remote and any applications already installed are left unchanged
