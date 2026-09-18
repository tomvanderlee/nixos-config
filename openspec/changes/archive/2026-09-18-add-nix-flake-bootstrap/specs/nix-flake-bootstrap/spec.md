## Purpose

Provides a single Nix flake that provisions NixOS hosts from a copyable template and provisions a shared, cross-platform home-manager user profile that installs standalone on non-NixOS systems, keeping both paths built from the same per-user module.

## ADDED Requirements

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
