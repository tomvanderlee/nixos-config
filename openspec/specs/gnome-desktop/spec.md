# gnome-desktop Specification

## Purpose

Provides a working GNOME desktop environment, including login, networking, audio, and printing, on every NixOS host built from this flake, unless the host is configured as headless.

## Requirements

### Requirement: GNOME is the default desktop on every NixOS host
Every NixOS host built from this flake's shared system module SHALL, unless it sets `desktop.enable = false`, boot into a GNOME desktop session via a graphical login manager, without requiring per-host opt-in.

#### Scenario: Graphical login is available after boot
- **WHEN** a NixOS host built from this flake's shared system module with the desktop enabled finishes booting
- **THEN** a graphical login manager is presented, and selecting the default session starts a GNOME desktop

### Requirement: Desktop networking is functional
The desktop environment SHALL provide working network configuration through its own UI, not require a separate manual networking setup step.

#### Scenario: Network settings are usable from the desktop
- **WHEN** a user opens the desktop's network configuration UI
- **THEN** available networks can be viewed and configured without additional manual setup outside the desktop environment

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

### Requirement: The desktop can be disabled per host
The shared system module SHALL expose a boolean option `desktop.enable` that defaults to `true`. When a host sets it to `false`, the host SHALL NOT enable the X server, a display manager, GNOME, desktop audio services, or printing and printer discovery services.

#### Scenario: Default keeps the desktop
- **WHEN** a host does not set `desktop.enable`
- **THEN** it is built with the full desktop stack, exactly as before this option existed

#### Scenario: Headless host has no graphical stack
- **WHEN** a host sets `desktop.enable = false`
- **THEN** its system closure enables no display manager, GNOME session, PipeWire, CUPS or Avahi, and it still boots to a console login with SSH reachable

### Requirement: The login screen shows real users by display name
On a desktop-enabled NixOS host built from this flake's shared system module, the graphical login screen SHALL list user `tom` by the display name "Tom" and SHALL NOT list the `root` account or other system accounts.

#### Scenario: Tom is shown with a capitalized name
- **WHEN** the graphical login screen is shown on a desktop-enabled host
- **THEN** the entry for the user is labelled "Tom", and logging in as it still uses the login name `tom`

#### Scenario: Root is not offered
- **WHEN** the graphical login screen is shown on a desktop-enabled host
- **THEN** no "System administrator" or `root` entry is present

#### Scenario: Headless host is unaffected
- **WHEN** a host sets `desktop.enable = false`
- **THEN** no AccountsService root override is configured, and the `tom` account still has its display name

### Requirement: Bluetooth media buttons reach media players
When the desktop is enabled, the host SHALL expose a media player for Bluetooth audio devices so that their play, pause and skip button events (AVRCP) control the desktop's media players, without requiring the user to configure the audio stack.

#### Scenario: Headset tap gestures control playback
- **WHEN** a Bluetooth headset connected to a desktop-enabled host sends a play, pause or skip event
- **THEN** the event is delivered to the active media player

#### Scenario: Headless host is unaffected
- **WHEN** a host sets `desktop.enable = false`
- **THEN** no audio-stack Bluetooth media player configuration is added

### Requirement: Phone integration is available through KDE Connect
When the desktop is enabled, every NixOS host built from this flake's shared system module SHALL provide a KDE Connect-compatible client integrated into the GNOME session, so a phone running the KDE Connect app can be paired with the host and share its clipboard, mirror notifications and send files, without per-host opt-in.

#### Scenario: Extension is active in a fresh session
- **WHEN** a user who has not changed GNOME's extension settings logs into a desktop-enabled host
- **THEN** the KDE Connect-compatible extension is enabled and offers a device list in the GNOME top bar

#### Scenario: Phone can be paired and shares the clipboard
- **WHEN** the user pairs a phone on the same local network by accepting the request on both devices and enables clipboard sharing
- **THEN** text copied on one device can be pasted on the other

#### Scenario: User can disable the extension
- **WHEN** the user turns the extension off in GNOME's extension settings
- **THEN** the choice takes effect and persists across future logins

### Requirement: Phone discovery is not blocked by the firewall
On a desktop-enabled host, the firewall SHALL allow the KDE Connect protocol's local-network traffic (TCP and UDP ports 1714 to 1764) so device discovery and pairing work without manual firewall changes.

#### Scenario: Phone on the LAN discovers the host
- **WHEN** a phone running the KDE Connect app is on the same local network as a desktop-enabled host
- **THEN** the phone lists the host as an available device to pair with

### Requirement: Headless hosts get no phone integration
A host that sets `desktop.enable = false` SHALL NOT install the KDE Connect-compatible client or open its ports.

#### Scenario: Headless host closure
- **WHEN** a host sets `desktop.enable = false`
- **THEN** the KDE Connect firewall ports are not opened and the extension is not installed
