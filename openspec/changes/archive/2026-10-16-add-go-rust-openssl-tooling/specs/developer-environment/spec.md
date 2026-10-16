# Spec Delta

## ADDED Requirements

### Requirement: The openssl command is provisioned
The shared home-manager profile SHALL provide the `openssl` command-line tool on `PATH`, identically on every platform where the profile is activated.

#### Scenario: openssl is available after activation
- **WHEN** the shared home profile is activated on a supported platform
- **THEN** `openssl version` runs successfully without any additional installation step
