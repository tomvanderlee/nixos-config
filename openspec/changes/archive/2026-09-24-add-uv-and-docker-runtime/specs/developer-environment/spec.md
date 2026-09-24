## MODIFIED Requirements

### Requirement: Container and cloud tools are client-only
Container and cloud-related packages provisioned by this capability SHALL provide client/CLI functionality only; they SHALL NOT attempt to provide or manage the underlying runtime or service (e.g. a Kubernetes cluster or cloud account), with one exception: Docker's runtime is managed on NixOS hosts by the separate `container-runtime` capability. Outside of NixOS hosts, and for every other tool (`kubectl`, `awscli2`), no corresponding runtime or account is installed or managed.

#### Scenario: No runtime is installed or managed
- **WHEN** a container or cloud CLI tool other than Docker is provisioned by the shared home profile
- **THEN** no corresponding daemon, virtual machine, or account configuration is installed or managed by this capability — the tool simply connects to whatever runtime or account is already configured on the system

#### Scenario: Docker's runtime is the documented exception on NixOS
- **WHEN** the Docker CLI is provisioned by the shared home profile on a NixOS host built from this flake's shared system module
- **THEN** a Docker runtime is available via the separate `container-runtime` capability, rather than being left entirely unmanaged
