## MODIFIED Requirements

### Requirement: Desktop GUI applications are provisioned via the shared home profile
The shared home-manager profile SHALL include Slack, Discord, Spotify, teams-for-linux, Firefox, and the Bitwarden desktop client as GUI application packages, available wherever that profile is activated and the underlying package supports the current system.

#### Scenario: GUI app available after activation
- **WHEN** the shared home profile is activated on a system for which a given desktop application's package is supported
- **THEN** that application is available without any additional manual installation step
