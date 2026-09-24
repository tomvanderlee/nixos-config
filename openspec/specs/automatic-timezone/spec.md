# automatic-timezone Specification

## Purpose

Keeps every NixOS host's system timezone in sync with its actual physical location automatically, so the system clock, GNOME's clock/calendar, and log timestamps reflect local time without any manual `timedatectl` step.

## Requirements

### Requirement: NixOS hosts detect and apply their timezone automatically
Every NixOS host built from this flake's shared system module SHALL determine its current timezone based on location and apply it to the system, without requiring the user to run a manual command or interactively authenticate the change.

#### Scenario: Timezone is applied after boot with network access
- **WHEN** a NixOS host built from this flake's shared system module boots with network connectivity available
- **THEN** the system's active timezone is set to the timezone matching the host's current location, without any interactive prompt

#### Scenario: No per-host opt-in required
- **WHEN** a NixOS host is built from this flake's shared system module and its own `hosts/<name>/configuration.nix` does not configure timezone detection itself
- **THEN** automatic timezone detection is still active, exactly as if it had been configured directly

### Requirement: A host can still pin an explicit fixed timezone
A NixOS host built from this flake SHALL be able to override automatic detection with a fixed, explicitly configured timezone when that host's own configuration requires one.

#### Scenario: Host-level override takes effect
- **WHEN** a host's own `hosts/<name>/configuration.nix` sets an explicit timezone at a priority higher than the shared default
- **THEN** that host uses the explicitly configured timezone instead of an automatically detected one
