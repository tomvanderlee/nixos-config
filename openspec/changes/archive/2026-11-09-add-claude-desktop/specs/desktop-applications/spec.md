# Spec Delta

## ADDED Requirements

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
