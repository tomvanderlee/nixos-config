# Spec Delta

## ADDED Requirements

### Requirement: The WireGuard command-line tools are provisioned
The shared home-manager profile SHALL provide the `wg` and `wg-quick` commands on `PATH`, identically on every platform where the profile is activated, for inspecting and manually managing WireGuard tunnels. The profile SHALL NOT create or configure any WireGuard interface, peer, key or firewall rule.

#### Scenario: WireGuard tools are available after activation
- **WHEN** the shared home profile is activated on a supported platform
- **THEN** `wg --version` and `command -v wg-quick` succeed without any additional installation step

#### Scenario: No tunnel is configured
- **WHEN** the shared home profile is activated on a host with no WireGuard configuration of its own
- **THEN** no WireGuard interface, peer or key is created, and `sudo wg show` lists no interfaces
