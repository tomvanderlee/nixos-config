## ADDED Requirements

### Requirement: Root pool is not force-imported
When `storage.zfs.enable` is true, the shared system module SHALL configure the boot process to import the root pool without forcing the import, so ZFS's guard against importing a pool in use by another host ID stays active. A host SHALL be able to override this with its own configuration.

#### Scenario: Default does not force the import
- **WHEN** a host sets `storage.zfs.enable = true` and does not set `boot.zfs.forceImportRoot`
- **THEN** `boot.zfs.forceImportRoot` evaluates to `false` and the evaluation emits no warning about it

#### Scenario: Host can force the import
- **WHEN** a host sets `boot.zfs.forceImportRoot = true` in its own configuration
- **THEN** that value takes effect instead of the shared default

#### Scenario: Non-ZFS hosts are unchanged
- **WHEN** a host does not enable `storage.zfs.enable`
- **THEN** the module does not set `boot.zfs.forceImportRoot`
