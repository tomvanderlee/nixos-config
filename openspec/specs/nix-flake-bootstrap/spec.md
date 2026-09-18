## Purpose

Provides a single Nix flake that provisions NixOS hosts from a copyable template and provisions a shared, cross-platform home-manager user profile that installs standalone on non-NixOS systems, keeping both paths built from the same per-user module.

## Requirements

### Requirement: Shared home profile across activation methods
The system SHALL apply the same home-manager user profile (shell, git, editor, CLI tools) whether it is activated as part of a NixOS system build or activated standalone via `home-manager switch` on a non-NixOS system.

#### Scenario: NixOS-activated profile matches standalone profile
- **WHEN** a NixOS host built with the `mkNixos` helper activates its `home-manager.users.tom` configuration
- **THEN** the resulting user environment includes the same programs and settings as the `homeConfigurations."tom@linux"` output built with the `mkHome` helper, because both consume the same `users/tom.nix` module

### Requirement: Standalone installation requires no root privileges
The system SHALL allow the shared home profile to be installed on any non-NixOS system without modifying system-level configuration or requiring root/sudo.

#### Scenario: Standalone home-manager switch
- **WHEN** a user with Nix installed runs `home-manager switch --flake .#tom@linux` on a non-NixOS Linux system
- **THEN** only the user's home directory is modified and no root privileges are required

### Requirement: NixOS host template is not a live flake output
The system SHALL provide a NixOS host template directory that is not wired into any `nixosConfigurations` output, so it cannot be accidentally built or installed before being customized for real hardware.

#### Scenario: Flake check does not build the template
- **WHEN** `nix flake check` is run against the repository
- **THEN** no `nixosConfigurations` entry evaluates or builds the `hosts/template` directory directly

### Requirement: Flakes remain enabled on installed NixOS systems
Every NixOS host built from this flake SHALL have the `nix-command` and `flakes` experimental features enabled by default, so subsequent `nixos-rebuild` invocations do not require extra flags.

#### Scenario: Rebuilding after install needs no extra flags
- **WHEN** a NixOS system installed from this flake is rebuilt with `nixos-rebuild switch --flake <path>#<host>`
- **THEN** the command succeeds without passing `--extra-experimental-features`

### Requirement: Per-host and per-user state versions are explicit
Each NixOS host and each home-manager user configuration SHALL declare its own `system.stateVersion` / `home.stateVersion` value; the shared helper functions SHALL NOT supply a default value.

#### Scenario: Missing stateVersion fails evaluation
- **WHEN** a host or user configuration omits its `stateVersion` setting
- **THEN** evaluating that configuration fails rather than silently falling back to a shared default

### Requirement: Repository evaluates under pure evaluation
The flake's `homeConfigurations` and check outputs defined in this change SHALL evaluate and build using only pure evaluation, without requiring the `--impure` flag.

#### Scenario: Pure flake check succeeds
- **WHEN** `nix flake check` is run without `--impure`
- **THEN** it completes successfully for all outputs defined in this change

### Requirement: Host directories are auto-discovered as flake outputs
Any directory under `hosts/` other than `hosts/template` that contains a valid host definition SHALL automatically become a `nixosConfigurations.<name>` output, without requiring any edit to `flake.nix`.

#### Scenario: New host directory becomes buildable without touching flake.nix
- **WHEN** a new directory `hosts/<name>/` is created containing `configuration.nix`, `hardware-configuration.nix`, and a `system` file, and `flake.nix` itself is left unmodified
- **THEN** `nixosConfigurations.<name>` evaluates successfully as part of the flake's outputs

#### Scenario: Template remains excluded from discovery
- **WHEN** the flake's outputs are evaluated
- **THEN** `hosts/template` does not appear as a `nixosConfigurations` entry, regardless of its contents

### Requirement: Host creation is scripted
The system SHALL provide a script that scaffolds a new NixOS host directory from the template, given a hostname, a target root path, and a state version.

#### Scenario: Scaffolding a new host
- **WHEN** the host creation script is run with a hostname, a `--root` path, and a `--state-version`
- **THEN** a `hosts/<hostname>/` directory is created containing a `configuration.nix` with the hostname and state version filled in, a `system` file, and a `hardware-configuration.nix` copied from the given root

#### Scenario: Refusing to overwrite an existing host
- **WHEN** the host creation script is run with a hostname that already has a `hosts/<hostname>/` directory, without an explicit override flag
- **THEN** the script fails without modifying the existing directory

### Requirement: Hardware configuration source is always explicit
The host creation script SHALL require an explicit root path for locating `hardware-configuration.nix` and SHALL NOT read from the invoking system's own `/etc/nixos` unless that path is explicitly given as the root.

#### Scenario: No root provided
- **WHEN** the host creation script is run without a root path specified
- **THEN** the script fails with an error rather than falling back to any default location

#### Scenario: Live installer environment targets the mounted install, not the live system
- **WHEN** the host creation script is run from a NixOS live/installer environment with `--root /mnt` pointing at a freshly mounted install target
- **THEN** the resulting `hardware-configuration.nix` is copied from `/mnt/etc/nixos/hardware-configuration.nix`, and the live environment's own `/etc/nixos/hardware-configuration.nix` is never read

#### Scenario: Hardware configuration cannot be found or generated
- **WHEN** the host creation script is run with a `--root` path that has no `hardware-configuration.nix` and no `nixos-generate-config` command is available to create one
- **THEN** the script fails with a clear error instead of proceeding with a missing or stub file

### Requirement: Install target matches the created host name
The host attribute produced for a newly scaffolded host SHALL exactly match the hostname given to the creation script, so the host can be installed or rebuilt via `<flake>#<hostname>`.

#### Scenario: Installing a newly scaffolded host
- **WHEN** a host is scaffolded with a given hostname
- **THEN** `nixos-install --flake <flake-path>#<hostname>` and `nixos-rebuild switch --flake <flake-path>#<hostname>` both resolve to the configuration that was just scaffolded
