## ADDED Requirements

### Requirement: GNOME Extension Manager is provisioned only where GNOME is enabled
GNOME Extension Manager SHALL be included in the provisioned package set only where the GNOME desktop is enabled (every NixOS host built from this flake's shared system module), and SHALL be excluded wherever GNOME is not known to be enabled, including standalone (non-NixOS) home-manager activations of the shared profile.

#### Scenario: Included on a NixOS host with GNOME enabled
- **WHEN** the shared home profile is activated as part of a NixOS host built from this flake's shared system module, where GNOME is enabled
- **THEN** GNOME Extension Manager is included in the provisioned package set

#### Scenario: Excluded on a standalone activation
- **WHEN** the shared home profile is activated standalone, not as part of a NixOS system (for example via `home-manager switch` on a non-NixOS machine)
- **THEN** GNOME Extension Manager is not included in the provisioned package set, regardless of the host's operating system
