# gnome-desktop Specification

## Purpose

Provides a working GNOME desktop environment, including login, networking, audio, and printing, on every NixOS host built from this flake.

## Requirements

### Requirement: GNOME is the default desktop on every NixOS host
Every NixOS host built from this flake's shared system module SHALL boot into a GNOME desktop session via a graphical login manager, without requiring per-host opt-in.

#### Scenario: Graphical login is available after boot
- **WHEN** a NixOS host built from this flake's shared system module finishes booting
- **THEN** a graphical login manager is presented, and selecting the default session starts a GNOME desktop

### Requirement: Desktop networking is functional
The desktop environment SHALL provide working network configuration through its own UI, not require a separate manual networking setup step.

#### Scenario: Network settings are usable from the desktop
- **WHEN** a user opens the desktop's network configuration UI
- **THEN** available networks can be viewed and configured without additional manual setup outside the desktop environment

### Requirement: Desktop audio is functional
The desktop environment SHALL provide working audio output and input, including compatibility with applications expecting a PulseAudio-compatible audio server.

#### Scenario: Audio applications can play sound
- **WHEN** an application on the desktop attempts to play or capture audio
- **THEN** the audio server is running and available to handle the request

### Requirement: Printing is supported and printers are discoverable
The desktop environment SHALL support printing to CUPS-compatible printers, and SHALL be able to discover network printers automatically without requiring the firewall to be manually reconfigured.

#### Scenario: A network printer is discoverable
- **WHEN** a network printer advertises itself on the local network
- **THEN** it can be discovered and configured for printing without the host's firewall blocking the discovery traffic
