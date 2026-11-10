## ADDED Requirements

### Requirement: LibrePods is provisioned on Linux systems
The shared home-manager profile SHALL include LibrePods (the AirPods control application and its `librepods-ctl` command) on Linux systems, and SHALL NOT include it on any other system. Like the other desktop GUI applications, it SHALL be omitted when `home.desktop.enable` is false.

#### Scenario: Available on a Linux desktop
- **WHEN** the shared home profile is activated on a Linux system with `home.desktop.enable` true
- **THEN** `librepods` is available to launch (command and application-menu entry) without any manual installation step

#### Scenario: Excluded on a non-Linux system
- **WHEN** the shared home profile is activated on a non-Linux system such as macOS
- **THEN** LibrePods is not included in the provisioned package set and evaluation still succeeds

#### Scenario: Excluded on a headless host
- **WHEN** a NixOS host sets `desktop.enable = false`
- **THEN** LibrePods is not installed for its users
