# Spec Delta

## ADDED Requirements

### Requirement: Nextcloud client can open its folder chooser
The provisioned Nextcloud desktop client SHALL be able to open its local-folder chooser, and therefore add a folder connection, without terminating, independent of which GTK or GNOME schema packages the desktop session exposes.

#### Scenario: Adding a folder connection
- **WHEN** the user starts the client (from the application menu or a terminal) and chooses a local folder while adding a folder connection
- **THEN** the folder chooser opens and the client keeps running

#### Scenario: Session lacks GTK3 schemas
- **WHEN** the desktop session's data directories do not include GTK3's settings schemas
- **THEN** the client still opens the folder chooser without aborting
