## ADDED Requirements

### Requirement: Bluetooth media buttons reach media players
When the desktop is enabled, the host SHALL expose a media player for Bluetooth audio devices so that their play, pause and skip button events (AVRCP) control the desktop's media players, without requiring the user to configure the audio stack.

#### Scenario: Headset tap gestures control playback
- **WHEN** a Bluetooth headset connected to a desktop-enabled host sends a play, pause or skip event
- **THEN** the event is delivered to the active media player

#### Scenario: Headless host is unaffected
- **WHEN** a host sets `desktop.enable = false`
- **THEN** no audio-stack Bluetooth media player configuration is added
