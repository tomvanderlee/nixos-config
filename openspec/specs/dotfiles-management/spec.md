## Purpose

Automatically clones a personal dotfiles repository into the user's home directory and symlinks its contents into place, so a fresh machine ends up with the same personal configuration without a manual clone-and-stow step.

## Requirements

### Requirement: Dotfiles cloning is opt-in via a configured repo URL
The dotfiles clone-and-stow behavior SHALL only run when a repository URL has been explicitly configured; leaving it unset SHALL leave the home directory untouched by this feature.

#### Scenario: No repo URL configured
- **WHEN** no dotfiles repository URL has been set
- **THEN** no clone or symlinking occurs during activation

#### Scenario: Repo URL configured
- **WHEN** a dotfiles repository URL has been set
- **THEN** activation clones and symlinks that repository as described by the other requirements in this capability

### Requirement: Existing dotfiles checkout is never overwritten
If the dotfiles repository has already been cloned locally, the system SHALL NOT re-clone or otherwise modify that existing checkout.

#### Scenario: Checkout already present
- **WHEN** activation runs and a local dotfiles checkout already exists
- **THEN** no clone operation is performed against that location, and the existing checkout's contents and git history are left untouched

#### Scenario: Checkout missing
- **WHEN** activation runs and no local dotfiles checkout exists yet
- **THEN** the configured repository is cloned, including any git submodules it declares

### Requirement: Dotfiles packages are symlinked into the home directory
Each top-level package directory in the cloned dotfiles repository SHALL be symlinked into the home directory following the same package-to-target-path convention as GNU Stow (a package directory's contents mirror their target location under the home directory).

#### Scenario: A package is linked
- **WHEN** the dotfiles repository contains a top-level directory whose contents mirror a location under the home directory
- **THEN** that content becomes reachable via a symlink at the corresponding path under the home directory

#### Scenario: Non-package entries are ignored
- **WHEN** the dotfiles repository contains top-level entries that are not package directories (ordinary files, or hidden/dot-prefixed directories such as version-control metadata)
- **THEN** those entries are not treated as packages and produce no symlinks

### Requirement: A conflicting package does not block the others
If symlinking one package would conflict with an existing file or symlink not owned by this process, the system SHALL skip that package and continue processing the remaining packages, rather than aborting entirely.

#### Scenario: One package conflicts
- **WHEN** one dotfiles package's target path is already occupied by an unrelated existing file
- **THEN** that package is skipped with a visible warning, and every other package is still processed

### Requirement: Platform-irrelevant packages are skipped
The system SHALL skip stowing a dotfiles package when that package is platform-irrelevant, either because it matches a built-in platform default (based on the current OS) or because it has been explicitly listed for exclusion, rather than always stowing every top-level package directory.

#### Scenario: A package is excluded by built-in platform default
- **WHEN** the dotfiles repository contains a top-level package directory that is known to be relevant only to a different platform than the one currently running (for example, a macOS-only package on a Linux system, or a Linux-only package on a macOS system)
- **THEN** that package is not symlinked, and a visible message indicates it was skipped as not relevant on this platform

#### Scenario: A package is excluded via explicit configuration
- **WHEN** a package name has been explicitly configured for exclusion, regardless of the built-in platform defaults
- **THEN** that package is not symlinked, and a visible message indicates it was skipped

#### Scenario: A non-excluded package is still stowed
- **WHEN** a top-level package directory is neither a built-in platform-mismatched package nor explicitly excluded
- **THEN** that package is symlinked into the home directory as described by the existing package-symlinking requirement

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
