# Spec Delta

## ADDED Requirements

### Requirement: The desktop can be disabled per host
The shared system module SHALL expose a boolean option `desktop.enable` that defaults to `true`. When a host sets it to `false`, the host SHALL NOT enable the X server, a display manager, GNOME, desktop audio services, or printing and printer discovery services.

#### Scenario: Default keeps the desktop
- **WHEN** a host does not set `desktop.enable`
- **THEN** it is built with the full desktop stack, exactly as before this option existed

#### Scenario: Headless host has no graphical stack
- **WHEN** a host sets `desktop.enable = false`
- **THEN** its system closure enables no display manager, GNOME session, PipeWire, CUPS or Avahi, and it still boots to a console login with SSH reachable

## MODIFIED Requirements

### Requirement: GNOME is the default desktop on every NixOS host
Every NixOS host built from this flake's shared system module SHALL, unless it sets `desktop.enable = false`, boot into a GNOME desktop session via a graphical login manager, without requiring per-host opt-in.

#### Scenario: Graphical login is available after boot
- **WHEN** a NixOS host built from this flake's shared system module with the desktop enabled finishes booting
- **THEN** a graphical login manager is presented, and selecting the default session starts a GNOME desktop

### Requirement: Desktop audio is functional
When the desktop is enabled, the desktop environment SHALL provide working audio output and input, including compatibility with applications expecting a PulseAudio-compatible audio server.

#### Scenario: Audio applications can play sound
- **WHEN** an application on a desktop-enabled host attempts to play or capture audio
- **THEN** the audio server is running and available to handle the request

### Requirement: Printing is supported and printers are discoverable
When the desktop is enabled, the host SHALL support printing to CUPS-compatible printers, and SHALL be able to discover network printers automatically without requiring the firewall to be manually reconfigured.

#### Scenario: A network printer is discoverable
- **WHEN** a network printer advertises itself on the local network of a desktop-enabled host
- **THEN** it can be discovered and configured for printing without the host's firewall blocking the discovery traffic

### Requirement: GNOME defaults to dark mode
Every desktop-enabled NixOS host built from this flake's shared system module SHALL configure its GNOME desktop session to use dark mode (`color-scheme: prefer-dark`) as the default appearance, while leaving the setting changeable by the user.

#### Scenario: Fresh session uses dark mode
- **WHEN** a user who has not previously changed the GNOME appearance setting logs into a desktop-enabled NixOS host built from this flake's shared system module
- **THEN** the GNOME desktop session appears in dark mode

#### Scenario: User can still switch to light mode
- **WHEN** a user opens GNOME Settings' Appearance page on a desktop-enabled host built from this flake's shared system module
- **THEN** the user can select light mode, and that choice takes effect and persists across future logins
