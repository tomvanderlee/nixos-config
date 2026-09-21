## Purpose

Ensures a login shell actually loads the user's bash configuration, since NixOS and most other Linux distributions don't ship a `~/.bash_profile` that sources `~/.bashrc` by default — without ever touching a `~/.bash_profile` that already exists.

## ADDED Requirements

### Requirement: A missing `.bash_profile` is created to source `.bashrc`
If no `~/.bash_profile` exists, home-manager activation SHALL create one whose contents source `~/.bashrc`.

#### Scenario: No `.bash_profile` exists
- **WHEN** activation runs and `~/.bash_profile` does not exist
- **THEN** a `~/.bash_profile` is created that sources `~/.bashrc`

### Requirement: An existing `.bash_profile` is never modified
If `~/.bash_profile` already exists in any form (regular file or symlink), activation SHALL NOT create, overwrite, or otherwise modify it.

#### Scenario: `.bash_profile` already exists
- **WHEN** activation runs and `~/.bash_profile` already exists
- **THEN** its contents are left completely unchanged, and no write is attempted

### Requirement: The created file tolerates a missing `.bashrc`
The generated `~/.bash_profile` SHALL only attempt to source `~/.bashrc` if that file exists, so it never errors on a login shell that runs before `~/.bashrc` is otherwise provisioned.

#### Scenario: `.bashrc` does not exist yet
- **WHEN** the generated `~/.bash_profile` runs and `~/.bashrc` does not exist
- **THEN** it does nothing further and produces no error

### Requirement: Behavior is identical on every platform this flake targets
This capability SHALL apply unconditionally wherever the shared home-manager profile is activated — NixOS, standalone Linux, and macOS alike — gated only by whether `~/.bash_profile` already exists, not by operating system.

#### Scenario: Activated on any supported platform
- **WHEN** the shared home profile is activated on NixOS, standalone Linux, or macOS
- **THEN** the same create-if-absent behavior for `~/.bash_profile` applies identically
