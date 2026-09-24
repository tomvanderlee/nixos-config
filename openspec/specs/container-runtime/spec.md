# container-runtime Specification

## Purpose

Provides a working, unprivileged Docker container runtime on every NixOS host built from this flake, so the already-provisioned Docker CLI tooling has a daemon to talk to without a separately-managed installation step.

## Requirements

### Requirement: A rootless Docker daemon runs on every NixOS host
Every NixOS host built from this flake's shared system module SHALL run a Docker daemon in rootless mode (as the user's own account, not as root), without requiring per-host opt-in.

#### Scenario: Daemon available after boot
- **WHEN** a NixOS host built from this flake's shared system module finishes booting and the user logs in
- **THEN** a Docker daemon is running under that user's own account, not as root

### Requirement: The Docker CLI connects to the rootless daemon without manual configuration
A user on a NixOS host built from this flake's shared system module SHALL be able to run Docker CLI commands (e.g. `docker run`, `docker build`) against the rootless daemon without manually setting `DOCKER_HOST` or other connection configuration.

#### Scenario: Docker command works out of the box
- **WHEN** a user runs a `docker` CLI command on a NixOS host built from this flake's shared system module
- **THEN** the command reaches the rootless daemon and executes, without the user having exported `DOCKER_HOST` or written any Docker connection config themselves
