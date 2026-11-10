# zfs Specification

## Purpose
Provides opt-in ZFS support for NixOS hosts built from this flake: a required host ID, scrub and trim, and boot-time unlock of an encrypted home dataset.

## Requirements

### Requirement: Opt-in ZFS support
The shared system module SHALL provide the option `storage.zfs.enable`, default `false`. When enabled, the host SHALL include `zfs` in `boot.supportedFilesystems` and enable `services.zfs.autoScrub` and `services.zfs.trim`. Hosts that do not enable it SHALL be unchanged.

#### Scenario: Default hosts have no ZFS
- **WHEN** a host that does not set `storage.zfs.enable` is evaluated
- **THEN** `boot.supportedFilesystems` does not contain `zfs`

#### Scenario: Enabled hosts get ZFS maintenance
- **WHEN** a host sets `storage.zfs.enable = true`
- **THEN** `services.zfs.autoScrub.enable` and `services.zfs.trim.enable` are true

### Requirement: Required host ID
`storage.zfs.hostId` SHALL have no default and SHALL accept only 8 lowercase hexadecimal characters. When ZFS is enabled, `networking.hostId` SHALL equal it.

#### Scenario: Host ID is applied
- **WHEN** a host sets `storage.zfs.enable = true` and `storage.zfs.hostId = "8425e349"`
- **THEN** `networking.hostId` evaluates to `8425e349`

#### Scenario: Missing or malformed host ID fails evaluation
- **WHEN** ZFS is enabled without `hostId`, or with a value that is not 8 lowercase hex characters
- **THEN** evaluation fails

### Requirement: Encrypted home unlocked at boot
`storage.zfs.encryptedHome.dataset` SHALL default to `null`. When set, `boot.zfs.requestEncryptionCredentials` SHALL be exactly that dataset, so its passphrase is requested during boot. When `null`, the module SHALL NOT set `boot.zfs.requestEncryptionCredentials`.

#### Scenario: Dataset is requested at boot
- **WHEN** a host enables ZFS and sets `storage.zfs.encryptedHome.dataset = "rpool/home"`
- **THEN** `boot.zfs.requestEncryptionCredentials` evaluates to `[ "rpool/home" ]`

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
