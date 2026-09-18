## ADDED Requirements

### Requirement: Platform-irrelevant packages are skipped
The system SHALL skip stowing a dotfiles package when that package is platform-irrelevant, either because it matches a built-in platform default (based on the current OS) or because it has been explicitly listed for exclusion, rather than always stowing every top-level package directory.

#### Scenario: A package is excluded by built-in platform default
- **WHEN** the dotfiles repository contains a top-level package directory that is known to be relevant only to a different platform than the one currently running (for example, a macOS-only package on a Linux system, or a Linux-only package on a macOS system)
- **THEN** that package is not symlinked, and a visible message indicates it was skipped as not relevant on this platform

#### Scenario: A package is excluded via explicit configuration
- **WHEN** a package name has been explicitly configured for exclusion, regardless of the built-in platform defaults
- **THEN** that package is not symlinked, and a visible message indicates it was skipped

#### Scenario: A non-excluded package is still stowed
- **WHEN** a top-level package directory is neither a built-in platform-mismatched package nor explicitly excluded
- **THEN** that package is symlinked into the home directory as described by the existing package-symlinking requirement
