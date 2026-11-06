# Spec Delta

## ADDED Requirements

### Requirement: Per-host fingerprint support
The `toms-thinkpad` host SHALL enable `services.fprintd`. Fingerprint support SHALL NOT be enabled in shared modules, so hosts without a reader are unchanged.

#### Scenario: ThinkPad has fprintd
- **WHEN** `nixosConfigurations.toms-thinkpad` is evaluated
- **THEN** `services.fprintd.enable` is true

#### Scenario: Other hosts are unchanged
- **WHEN** any other host is evaluated
- **THEN** `services.fprintd.enable` is false
