## ADDED Requirements

### Requirement: GNOME defaults to dark mode
Every NixOS host built from this flake's shared system module SHALL configure its GNOME desktop session to use dark mode (`color-scheme: prefer-dark`) as the default appearance, while leaving the setting changeable by the user.

#### Scenario: Fresh session uses dark mode
- **WHEN** a user who has not previously changed the GNOME appearance setting logs into a NixOS host built from this flake's shared system module
- **THEN** the GNOME desktop session appears in dark mode

#### Scenario: User can still switch to light mode
- **WHEN** a user opens GNOME Settings' Appearance page on a host built from this flake's shared system module
- **THEN** the user can select light mode, and that choice takes effect and persists across future logins
