## ADDED Requirements

### Requirement: Optional push-target origin remote after initial clone
When a push-target URL has been configured in addition to the clone URL, the system SHALL, immediately after the initial clone, record the clone source as a remote named `github` and add a remote named `origin` pointing at the push-target URL, and configure the checked-out branch to track `origin` rather than `github`. When no push-target URL is configured, the clone SHALL keep git's default behavior (a single remote named `origin` pointing at the clone URL).

#### Scenario: Fresh clone with push target configured
- **WHEN** activation clones the dotfiles repository and a push-target URL is configured
- **THEN** the new checkout has a remote `github` for the configured clone URL and a remote `origin` for the push-target URL, and the checked-out branch's upstream is `origin`

#### Scenario: Fresh clone without push target
- **WHEN** activation clones the dotfiles repository and no push-target URL is configured
- **THEN** the new checkout has only the default remote `origin` for the configured clone URL

#### Scenario: Existing checkout keeps its remotes
- **WHEN** activation runs and a local dotfiles checkout already exists, with a push-target URL configured
- **THEN** the checkout's remotes are not added, renamed, or changed
