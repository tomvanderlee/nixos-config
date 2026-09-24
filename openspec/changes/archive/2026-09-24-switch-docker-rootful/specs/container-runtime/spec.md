## REMOVED Requirements

### Requirement: A rootless Docker daemon runs on every NixOS host
**Reason**: Switched to a standard rootful Docker daemon — the rootless per-user systemd service didn't reliably start in already-logged-in sessions, causing real `docker` CLI failures in practice.
**Migration**: Replaced by "A Docker daemon runs on every NixOS host" below.

### Requirement: The Docker CLI connects to the rootless daemon without manual configuration
**Reason**: Rootful Docker uses the standard system-wide socket path and `docker`-group membership instead of a per-session `DOCKER_HOST` export, so this requirement no longer applies.
**Migration**: Replaced by "The user account has access to the Docker socket" below.

## ADDED Requirements

### Requirement: A Docker daemon runs on every NixOS host
Every NixOS host built from this flake's shared system module SHALL run a Docker daemon as a system-level service, started at boot rather than tied to a user login session, without requiring per-host opt-in.

#### Scenario: Daemon available after boot
- **WHEN** a NixOS host built from this flake's shared system module finishes booting
- **THEN** a Docker daemon is running as a system service, independent of whether any user has logged in

### Requirement: The user account has access to the Docker socket
The user account provisioned on a NixOS host built from this flake's shared system module SHALL be a member of the group that grants access to the Docker daemon's socket, so Docker CLI commands work without `sudo` or manual connection configuration.

#### Scenario: Docker command works without sudo
- **WHEN** the provisioned user runs a `docker` CLI command on a NixOS host built from this flake's shared system module
- **THEN** the command reaches the daemon and executes, without requiring `sudo` or any manually exported connection configuration
