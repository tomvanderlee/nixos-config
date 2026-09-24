## Purpose

Provisions typefaces through the shared home-manager profile, starting with the JetBrains Mono Nerd Font, so that glyph-dependent terminal and editor UIs render correctly wherever that profile is activated.

## ADDED Requirements

### Requirement: JetBrains Mono Nerd Font is provisioned via the shared home profile
The shared home-manager profile SHALL include the JetBrains Mono Nerd Font as a package, available wherever that profile is activated and the underlying package supports the current system.

#### Scenario: Font available after activation
- **WHEN** the shared home profile is activated on a system for which the JetBrains Mono Nerd Font package is supported
- **THEN** the font is installed and resolvable by name by font-aware applications, without any additional manual installation step

### Requirement: The font package is skipped, not failed, on unsupported systems
On a system for which the JetBrains Mono Nerd Font package has no supported build, the package SHALL be omitted from the provisioned package set rather than causing profile evaluation or activation to fail.

#### Scenario: Unsupported system excluded without failure
- **WHEN** the shared home profile is evaluated on a system for which the JetBrains Mono Nerd Font package has no supported build
- **THEN** the font package is excluded from the provisioned set and the rest of the profile evaluates and activates successfully

### Requirement: The font is discoverable by fontconfig-based applications
On a Linux activation of the shared home profile, fontconfig SHALL be configured to discover fonts installed through the profile's packages, so that fontconfig-based applications (including the terminal and editor provisioned elsewhere in this profile) can resolve the JetBrains Mono Nerd Font by name.

#### Scenario: Font resolvable via fontconfig after activation
- **WHEN** the shared home profile is activated on a Linux system, whether standalone or as part of a NixOS host
- **THEN** a fontconfig-based application can enumerate and select the JetBrains Mono Nerd Font by name without additional manual font-cache configuration
