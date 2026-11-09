# wireguard-auto-connect Specification

## Purpose
Automatically bring an existing NetworkManager WireGuard profile up on untrusted networks and down on trusted ones, while leaving manual control from the desktop network UI intact.

## Requirements

### Requirement: Opt-in auto-connect option
The shared system module SHALL provide the option `vpn.autoConnect.enable`, default `false`, together with `vpn.autoConnect.connectionName` (default `"Home"`) naming the NetworkManager profile to manage and `vpn.autoConnect.trustedSsids` (default empty list) naming trusted Wi-Fi networks. Hosts that do not enable it, including anything scaffolded from `hosts/template`, SHALL have no auto-connect behavior.

#### Scenario: Default hosts are unchanged
- **WHEN** a host that does not set `vpn.autoConnect.enable` is evaluated
- **THEN** no NetworkManager dispatcher script for VPN auto-connect is installed

#### Scenario: The ThinkPad enables it
- **WHEN** `hosts/toms-thinkpad` is evaluated
- **THEN** `vpn.autoConnect.enable` is true, `connectionName` is `"Home"` and `trustedSsids` is `[ "ErmeLan" ]`

### Requirement: Untrusted networks bring the VPN up
When the option is enabled and a physical network comes up or goes down, the system SHALL activate the configured profile if it is not already active and the network is untrusted. A network state is untrusted when at least one Wi-Fi connection is active, no wired connection is active, and no active Wi-Fi connection has an SSID in `trustedSsids`.

#### Scenario: Joining an unknown Wi-Fi network
- **WHEN** the machine connects to Wi-Fi SSID `Tom’s iPhone` with no wired connection active
- **THEN** the configured profile becomes active

#### Scenario: Unplugging the cable on an untrusted Wi-Fi network
- **WHEN** the wired connection goes down while the active Wi-Fi SSID is not trusted
- **THEN** the configured profile becomes active

### Requirement: Trusted networks bring the VPN down
When the option is enabled and a physical network comes up or goes down, the system SHALL deactivate the configured profile if it is active and the network is trusted. A network state is trusted when any wired connection is active, or any active Wi-Fi connection has an SSID in `trustedSsids`.

#### Scenario: Joining the trusted Wi-Fi network
- **WHEN** the machine connects to SSID `ErmeLan` while the profile is active
- **THEN** the configured profile becomes inactive

#### Scenario: Plugging in a cable
- **WHEN** a wired connection comes up while the profile is active
- **THEN** the configured profile becomes inactive, even if an untrusted Wi-Fi connection is also active

### Requirement: Offline state and non-physical devices are ignored
The system SHALL NOT change the profile's state when no wired or Wi-Fi connection is active, nor in response to events from non-physical devices (the VPN interface itself, container bridges, loopback).

#### Scenario: All networks drop
- **WHEN** the last physical connection goes down
- **THEN** the profile's state is not changed by the script

#### Scenario: Docker bridge changes
- **WHEN** a docker bridge interface comes up or down
- **THEN** the profile's state is not changed

### Requirement: Manual control is preserved
The system SHALL NOT set `connection.autoconnect` or any other persistent property on the configured profile, and SHALL act only in response to physical network up/down events. A user toggling the profile in the desktop network UI or with `nmcli` SHALL keep that state until the next such event.

#### Scenario: Turning the VPN off manually on an untrusted network
- **WHEN** the user disconnects the profile from the GNOME network menu on an untrusted Wi-Fi network and no network event occurs afterwards
- **THEN** the profile stays inactive

#### Scenario: Turning the VPN on manually at home
- **WHEN** the user connects the profile from the GNOME network menu while on a trusted network and no network event occurs afterwards
- **THEN** the profile stays active

#### Scenario: Profile left unmodified
- **WHEN** the profile's `connection.autoconnect` is inspected after the script has run
- **THEN** it has the value the user set in GNOME Settings (`no` by default)

### Requirement: Missing profile is not an error
If no NetworkManager connection named `connectionName` exists, the script SHALL log the condition and exit successfully without affecting other dispatcher scripts or network connectivity.

#### Scenario: Profile not yet created
- **WHEN** the option is enabled, the named profile does not exist and a network comes up
- **THEN** a log line is written to the journal and no connection changes state
