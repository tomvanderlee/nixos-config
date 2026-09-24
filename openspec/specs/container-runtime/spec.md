# container-runtime Specification

## Purpose

Provides a working Docker container runtime on every NixOS host built from this flake, so the already-provisioned Docker CLI tooling has a daemon to talk to without a separately-managed installation step.

## Requirements

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
