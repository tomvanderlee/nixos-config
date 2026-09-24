## MODIFIED Requirements

### Requirement: Desktop GUI applications are provisioned via the shared home profile
The shared home-manager profile SHALL include Slack, Discord, Spotify, teams-for-linux, Firefox, the Bitwarden desktop client, and Ghostty as GUI application packages, available wherever that profile is activated and the underlying package supports the current system. GNOME Tweaks is provisioned per the separate requirement below, since its availability depends on GNOME being enabled rather than on platform support alone.

#### Scenario: GUI app available after activation
- **WHEN** the shared home profile is activated on a system for which a given desktop application's package is supported
- **THEN** that application is available without any additional manual installation step

## ADDED Requirements

### Requirement: GNOME Tweaks is provisioned only where GNOME is enabled
GNOME Tweaks SHALL be included in the provisioned package set only where the GNOME desktop is enabled (every NixOS host built from this flake's shared system module), and SHALL be excluded wherever GNOME is not known to be enabled, including standalone (non-NixOS) home-manager activations of the shared profile.

#### Scenario: Included on a NixOS host with GNOME enabled
- **WHEN** the shared home profile is activated as part of a NixOS host built from this flake's shared system module, where GNOME is enabled
- **THEN** GNOME Tweaks is included in the provisioned package set

#### Scenario: Excluded on a standalone activation
- **WHEN** the shared home profile is activated standalone, not as part of a NixOS system (for example via `home-manager switch` on a non-NixOS machine)
- **THEN** GNOME Tweaks is not included in the provisioned package set, regardless of the host's operating system
