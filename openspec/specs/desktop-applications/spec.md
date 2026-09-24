# desktop-applications Specification

## Purpose

Provisions everyday desktop GUI applications (chat, communication, and music clients) through the shared home-manager profile, mirroring how `developer-environment` provisions CLI tooling but for user-facing graphical applications instead.

## Requirements

### Requirement: Desktop GUI applications are provisioned via the shared home profile
The shared home-manager profile SHALL include Slack, Discord, Spotify, teams-for-linux, Firefox, the Bitwarden desktop client, and Ghostty as GUI application packages, available wherever that profile is activated and the underlying package supports the current system. GNOME Tweaks is provisioned per the separate requirement below, since its availability depends on GNOME being enabled rather than on platform support alone.

#### Scenario: GUI app available after activation
- **WHEN** the shared home profile is activated on a system for which a given desktop application's package is supported
- **THEN** that application is available without any additional manual installation step

### Requirement: Packages unsupported on the current system are skipped, not failed
A desktop application package that has no supported build for the currently evaluated system SHALL be omitted from the provisioned package set rather than causing profile evaluation or activation to fail.

#### Scenario: Unsupported package excluded without failure
- **WHEN** the shared home profile is evaluated on a system for which one of the desktop application packages (e.g. an `aarch64-linux` target lacking a Discord, Spotify, or Slack build) has no supported build
- **THEN** that package is excluded from the provisioned set and the rest of the profile evaluates and activates successfully

### Requirement: teams-for-linux is Linux-only
teams-for-linux SHALL be provisioned only on Linux systems, consistent with its scope as a Linux-only Microsoft Teams client.

#### Scenario: Excluded on a non-Linux system
- **WHEN** the shared home profile is activated on a non-Linux system
- **THEN** teams-for-linux is not included in the provisioned package set

### Requirement: GNOME Tweaks is provisioned only where GNOME is enabled
GNOME Tweaks SHALL be included in the provisioned package set only where the GNOME desktop is enabled (every NixOS host built from this flake's shared system module), and SHALL be excluded wherever GNOME is not known to be enabled, including standalone (non-NixOS) home-manager activations of the shared profile.

#### Scenario: Included on a NixOS host with GNOME enabled
- **WHEN** the shared home profile is activated as part of a NixOS host built from this flake's shared system module, where GNOME is enabled
- **THEN** GNOME Tweaks is included in the provisioned package set

#### Scenario: Excluded on a standalone activation
- **WHEN** the shared home profile is activated standalone, not as part of a NixOS system (for example via `home-manager switch` on a non-NixOS machine)
- **THEN** GNOME Tweaks is not included in the provisioned package set, regardless of the host's operating system
