# Spec Delta

## ADDED Requirements

### Requirement: Bitwarden fingerprint unlock
The `toms-thinkpad` host SHALL enable polkit and SHALL include `bitwarden-desktop` in `environment.systemPackages`, so the system polkit daemon can find Bitwarden's polkit policy and authenticate through the fingerprint reader. Fingerprint authentication SHALL remain enabled for the `polkit-1` PAM service.

#### Scenario: Polkit enabled with Bitwarden policy available
- **WHEN** `nixosConfigurations.toms-thinkpad` is evaluated
- **THEN** `security.polkit.enable` is true and `environment.systemPackages` contains `bitwarden-desktop`

#### Scenario: Polkit prompts use the fingerprint
- **WHEN** `nixosConfigurations.toms-thinkpad` is evaluated
- **THEN** `security.pam.services.polkit-1.fprintAuth` is true
