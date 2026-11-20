## ADDED Requirements

### Requirement: Bluetooth devices recover after resume from suspend
When the desktop is enabled and the host has Bluetooth enabled, the host SHALL restart the Bluetooth daemon after each resume from suspend, so that bonded Bluetooth input devices that fail to reconnect on their own after resume (such as the Logitech MX Master LE mouse) reconnect without the user removing and re-pairing them.

#### Scenario: Mouse reconnects after resume
- **WHEN** a desktop-enabled host with Bluetooth enabled resumes from suspend and a bonded, trusted Bluetooth mouse is then activated (for example by clicking a button)
- **THEN** the mouse reconnects without the user re-pairing it or restarting any service by hand

#### Scenario: Bluetooth is restarted only when it was running
- **WHEN** a host resumes from suspend while the Bluetooth daemon is not running
- **THEN** the resume step does not start the daemon

#### Scenario: Host without Bluetooth is unaffected
- **WHEN** a desktop-enabled host has Bluetooth disabled, or a host sets `desktop.enable = false`
- **THEN** no resume-time Bluetooth restart is configured
