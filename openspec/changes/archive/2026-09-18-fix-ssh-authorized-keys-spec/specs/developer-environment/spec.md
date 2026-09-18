## MODIFIED Requirements

### Requirement: SSH access is enabled by default on NixOS hosts
Every NixOS host built from this flake's shared system module SHALL have an SSH server enabled, with password authentication and root login disabled, and SHALL permit inbound SSH traffic through its firewall. The system SHALL also provision at least one authorized public key for the user, so that key-based authentication is actually reachable rather than merely configured.

#### Scenario: SSH reachable with key-based auth only
- **WHEN** a NixOS host is built from the shared system module
- **THEN** the SSH service is enabled, password authentication and root login are disabled, and the firewall permits inbound connections on the SSH port

#### Scenario: An authorized key is provisioned
- **WHEN** a NixOS host is built from the shared system module
- **THEN** the user account has at least one authorized public key configured, so a matching private key can actually authenticate over SSH
