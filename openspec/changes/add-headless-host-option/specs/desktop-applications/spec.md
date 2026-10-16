# Spec Delta

## ADDED Requirements

### Requirement: Desktop applications are skipped when the desktop is disabled
The shared home profile SHALL provision no desktop GUI applications when the desktop is disabled. The setting SHALL follow the host's `desktop.enable` when activated through a NixOS host, SHALL default to enabled on standalone activations, and SHALL be overridable on standalone activations through `home.desktop.enable`.

#### Scenario: Headless NixOS host gets no GUI apps
- **WHEN** the shared home profile is activated as part of a NixOS host with `desktop.enable = false`
- **THEN** none of the desktop GUI applications (including GNOME Tweaks and GNOME Extension Manager) are in the provisioned package set, while CLI tools are unaffected

#### Scenario: Standalone activation can opt out
- **WHEN** a standalone activation sets `home.desktop.enable = false`
- **THEN** no desktop GUI applications are provisioned

#### Scenario: Default is unchanged
- **WHEN** neither option is set
- **THEN** the provisioned GUI application set is the same as before this option existed
