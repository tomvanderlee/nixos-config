# Spec Delta

## ADDED Requirements

### Requirement: Portable network and file utilities are provisioned
The shared home-manager profile SHALL provide DNS lookup tools (`dig`, `nslookup`, `host`), `whois`, `nmap`, `mtr`, `nc`, `curl`, `wget`, `rsync`, `zip`, `unzip`, `7z`, `file`, `ncdu`, `watch` and `less` on `PATH`. A tool unavailable on the activating platform SHALL be omitted without failing activation.

#### Scenario: Utilities are available after activation
- **WHEN** the shared home profile is activated on a supported platform
- **THEN** `dig example.com`, `nslookup example.com` and `rsync --version` run without any additional installation step

#### Scenario: Unsupported platform drops a tool silently
- **WHEN** the profile is evaluated on a platform where one of these packages is unsupported
- **THEN** evaluation succeeds and only that tool is absent

### Requirement: System diagnostics are provisioned on NixOS hosts
Every NixOS host built from this flake's shared system module SHALL provide `tcpdump`, `traceroute`, `lsof`, `strace`, `fuser`, `killall`, `lspci`, `lsusb`, `iotop` and `ethtool` system-wide, available to every user including root.

#### Scenario: Diagnostics available to root
- **WHEN** a NixOS host built from the shared system module is running
- **THEN** `sudo lsof -v` and `sudo tcpdump --version` succeed

### Requirement: Utilities add no privileges or services
Provisioning these utilities SHALL NOT create setuid or capability wrappers, daemons, firewall rules or user groups. Tools that need raw sockets or elevated capabilities are run via `sudo`.

#### Scenario: No wrappers are created
- **WHEN** the shared system module is built
- **THEN** no new entry exists in `security.wrappers` and no new service is enabled as a result of these utilities

### Requirement: The openspec command is provisioned
The shared home-manager profile SHALL provide the `openspec` command-line tool on `PATH`, identically on every platform where the profile is activated.

#### Scenario: openspec is available after activation
- **WHEN** the shared home profile is activated on a supported platform
- **THEN** `openspec --version` succeeds without any additional installation step
