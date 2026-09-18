## Purpose

Provisions the developer's most-used CLI/client tooling through the shared home-manager profile and enables common baseline system services, such as SSH access, on every NixOS host built from this flake.

## Requirements

### Requirement: Developer CLI tools are provisioned via the shared home profile
The shared home-manager profile SHALL include the user's evidenced most-used CLI and client tools, available identically wherever that profile is activated (standalone or via a NixOS host).

#### Scenario: Tooling available after activation
- **WHEN** the shared home profile is activated on any supported platform
- **THEN** the provisioned developer CLI tools are available on `PATH` without any additional manual installation step

### Requirement: Container and cloud tools are client-only
Container and cloud-related packages provisioned by this capability SHALL provide client/CLI functionality only; they SHALL NOT attempt to provide or manage the underlying runtime or service (e.g. a container engine or cloud account).

#### Scenario: No runtime is installed or managed
- **WHEN** a container or cloud CLI tool is provisioned by the shared home profile
- **THEN** no corresponding daemon, virtual machine, or account configuration is installed or managed by this capability — the tool simply connects to whatever runtime or account is already configured on the system

### Requirement: Shell and prompt configuration defers to the user's personal dotfiles
Where the user's personal dotfiles repository already owns a piece of shell or prompt configuration, the shared home profile SHALL provide only the underlying package, not a competing managed configuration for that same file.

#### Scenario: Prompt tool provisioned without managed config
- **WHEN** the shared home profile provisions a prompt tool whose configuration is already owned by the user's dotfiles repository
- **THEN** the profile installs the tool's package but does not generate or manage a competing configuration file for it

### Requirement: SSH access is enabled by default on NixOS hosts
Every NixOS host built from this flake's shared system module SHALL have an SSH server enabled, with password authentication and root login disabled, and SHALL permit inbound SSH traffic through its firewall.

#### Scenario: SSH reachable with key-based auth only
- **WHEN** a NixOS host is built from the shared system module
- **THEN** the SSH service is enabled, password authentication and root login are disabled, and the firewall permits inbound connections on the SSH port
