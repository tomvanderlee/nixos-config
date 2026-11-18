# Spec Delta

## ADDED Requirements

### Requirement: RawTherapee is provisioned for viewing camera RAW photos
The shared home-manager profile SHALL include RawTherapee as a GUI application wherever the desktop is enabled and its package is supported, so camera RAW photos, including Apple ProRAW DNG files, can be opened without a locally compiled package.

#### Scenario: RawTherapee available after activation
- **WHEN** the shared home profile is activated with the desktop enabled on a supported platform
- **THEN** RawTherapee is available without any additional installation step

#### Scenario: Apple ProRAW file opens
- **WHEN** the user opens an Apple ProRAW DNG photo (for example from an iPhone 16 Pro Max), whether named `.dng` or `.raw`, in RawTherapee
- **THEN** the image is displayed

#### Scenario: Skipped when the desktop is disabled
- **WHEN** a host sets `desktop.enable = false`
- **THEN** RawTherapee is not installed
