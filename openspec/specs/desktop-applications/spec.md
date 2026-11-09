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

### Requirement: GNOME Extension Manager is provisioned only where GNOME is enabled
GNOME Extension Manager SHALL be included in the provisioned package set only where the GNOME desktop is enabled (every NixOS host built from this flake's shared system module), and SHALL be excluded wherever GNOME is not known to be enabled, including standalone (non-NixOS) home-manager activations of the shared profile.

#### Scenario: Included on a NixOS host with GNOME enabled
- **WHEN** the shared home profile is activated as part of a NixOS host built from this flake's shared system module, where GNOME is enabled
- **THEN** GNOME Extension Manager is included in the provisioned package set

#### Scenario: Excluded on a standalone activation
- **WHEN** the shared home profile is activated standalone, not as part of a NixOS system (for example via `home-manager switch` on a non-NixOS machine)
- **THEN** GNOME Extension Manager is not included in the provisioned package set, regardless of the host's operating system

### Requirement: Claude Desktop is provisioned on supported Linux systems
The shared home-manager profile SHALL include the Claude Desktop application, built from Anthropic's official Linux release, on Linux systems where a supported build exists, and SHALL NOT include it on any other system.

#### Scenario: Available on a supported Linux system
- **WHEN** the shared home profile is activated on an `x86_64-linux` or `aarch64-linux` system
- **THEN** Claude Desktop is available to launch (command and application-menu entry) without any manual installation step

#### Scenario: Excluded on a non-Linux system
- **WHEN** the shared home profile is activated on a non-Linux system such as macOS
- **THEN** Claude Desktop is not included and the profile still evaluates and activates successfully

### Requirement: Claude Desktop is a pinned, hash-verified release
The Claude Desktop package SHALL be pinned to a specific upstream version and verified by content hash, so builds are reproducible and never silently change with upstream.

#### Scenario: Upstream publishes a new release
- **WHEN** Anthropic publishes a newer Claude Desktop release
- **THEN** the provisioned version does not change until the pinned version and hashes are updated in this repository

### Requirement: Claude Desktop is permitted through the unfree allowlist
Claude Desktop SHALL be permitted by name in the explicit unfree allowlist, without enabling unfree packages globally.

#### Scenario: Evaluation with the allowlist
- **WHEN** the profile is evaluated with Claude Desktop included
- **THEN** evaluation succeeds, and an unfree package not on the allowlist is still rejected

### Requirement: Nextcloud desktop client is provisioned where supported
The shared home-manager profile SHALL include the Nextcloud desktop sync client as a GUI application on systems where it is supported, and SHALL omit it, without failing evaluation, on systems where it is not.

#### Scenario: Available on Linux
- **WHEN** the shared home profile is activated on a supported Linux system
- **THEN** the Nextcloud desktop client is available to launch without any manual installation step

#### Scenario: Omitted on an unsupported system
- **WHEN** the shared home profile is evaluated on a system with no supported Nextcloud client build, such as macOS
- **THEN** the client is excluded and the rest of the profile evaluates and activates successfully

### Requirement: Nextcloud client can open its folder chooser
The provisioned Nextcloud desktop client SHALL be able to open its local-folder chooser, and therefore add a folder connection, without terminating, independent of which GTK or GNOME schema packages the desktop session exposes.

#### Scenario: Adding a folder connection
- **WHEN** the user starts the client (from the application menu or a terminal) and chooses a local folder while adding a folder connection
- **THEN** the folder chooser opens and the client keeps running

#### Scenario: Session lacks GTK3 schemas
- **WHEN** the desktop session's data directories do not include GTK3's settings schemas
- **THEN** the client still opens the folder chooser without aborting
