# Spec Delta

## ADDED Requirements

### Requirement: Firefox runs through XWayland
The provisioned Firefox SHALL start with the native Wayland backend disabled, so that on a Wayland session it runs through XWayland instead. This SHALL hold however Firefox is launched (command line or application menu), without requiring the user to set any environment variable.

#### Scenario: Window protocol after launch
- **WHEN** the user launches Firefox from the application menu or a terminal in a GNOME Wayland session and opens `about:support`
- **THEN** the Window Protocol entry reads `x11`

#### Scenario: Still provisioned like other desktop apps
- **WHEN** the shared home profile is activated with `home.desktop.enable` false
- **THEN** Firefox is not provisioned, as for every other desktop GUI application

### Requirement: Firefox keeps its system integration
The provisioned Firefox SHALL retain the integration the unwrapped nixpkgs Firefox provides, including its native-messaging host lookup (as used by Bitwarden and the GNOME Shell browser connector) and its application-menu entry.

#### Scenario: Native messaging hosts still resolve
- **WHEN** a native-messaging host is made available to Firefox through the nixpkgs wrapper's host mechanism
- **THEN** the XWayland-wrapped Firefox discovers it exactly as the unwrapped one would

#### Scenario: Menu entry unchanged
- **WHEN** the shared home profile is activated
- **THEN** a single Firefox application-menu entry exists and launches the wrapped binary
