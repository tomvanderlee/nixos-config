# fingerprint-authentication Specification

## Purpose
TBD - created by archiving change add-thinkpad-fingerprint. Update Purpose after archive.

## Requirements

### Requirement: Per-host fingerprint support
The `toms-thinkpad` host SHALL enable `services.fprintd`. Fingerprint support SHALL NOT be enabled in shared modules, so hosts without a reader are unchanged.

#### Scenario: ThinkPad has fprintd
- **WHEN** `nixosConfigurations.toms-thinkpad` is evaluated
- **THEN** `services.fprintd.enable` is true

#### Scenario: Other hosts are unchanged
- **WHEN** any other host is evaluated
- **THEN** `services.fprintd.enable` is false

### Requirement: Bitwarden fingerprint unlock
The `toms-thinkpad` host SHALL enable polkit and SHALL include `bitwarden-desktop` in `environment.systemPackages`, so the system polkit daemon can find Bitwarden's polkit policy and authenticate through the fingerprint reader. Fingerprint authentication SHALL remain enabled for the `polkit-1` PAM service.

#### Scenario: Polkit enabled with Bitwarden policy available
- **WHEN** `nixosConfigurations.toms-thinkpad` is evaluated
- **THEN** `security.polkit.enable` is true and `environment.systemPackages` contains `bitwarden-desktop`

#### Scenario: Polkit prompts use the fingerprint
- **WHEN** `nixosConfigurations.toms-thinkpad` is evaluated
- **THEN** `security.pam.services.polkit-1.fprintAuth` is true
