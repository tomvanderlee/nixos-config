# Spec Delta

## ADDED Requirements

### Requirement: Nextcloud desktop client is provisioned where supported
The shared home-manager profile SHALL include the Nextcloud desktop sync client as a GUI application on systems where it is supported, and SHALL omit it, without failing evaluation, on systems where it is not.

#### Scenario: Available on Linux
- **WHEN** the shared home profile is activated on a supported Linux system
- **THEN** the Nextcloud desktop client is available to launch without any manual installation step

#### Scenario: Omitted on an unsupported system
- **WHEN** the shared home profile is evaluated on a system with no supported Nextcloud client build, such as macOS
- **THEN** the client is excluded and the rest of the profile evaluates and activates successfully
