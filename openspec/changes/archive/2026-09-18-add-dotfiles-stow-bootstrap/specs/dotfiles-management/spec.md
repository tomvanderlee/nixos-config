## Purpose

Automatically clones a personal dotfiles repository into the user's home directory and symlinks its contents into place, so a fresh machine ends up with the same personal configuration without a manual clone-and-stow step.

## ADDED Requirements

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
