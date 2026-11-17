## ADDED Requirements

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
