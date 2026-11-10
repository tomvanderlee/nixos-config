## ADDED Requirements

### Requirement: The login screen shows real users by display name
On a desktop-enabled NixOS host built from this flake's shared system module, the graphical login screen SHALL list user `tom` by the display name "Tom" and SHALL NOT list the `root` account or other system accounts.

#### Scenario: Tom is shown with a capitalized name
- **WHEN** the graphical login screen is shown on a desktop-enabled host
- **THEN** the entry for the user is labelled "Tom", and logging in as it still uses the login name `tom`

#### Scenario: Root is not offered
- **WHEN** the graphical login screen is shown on a desktop-enabled host
- **THEN** no "System administrator" or `root` entry is present

#### Scenario: Headless host is unaffected
- **WHEN** a host sets `desktop.enable = false`
- **THEN** no AccountsService root override is configured, and the `tom` account still has its display name
