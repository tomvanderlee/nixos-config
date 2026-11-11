# Spec Delta

## ADDED Requirements

### Requirement: The major cloud providers' command-line tools are provisioned
The shared home-manager profile SHALL provide the AWS CLI (`aws`), the Azure CLI (`az`) and the Google Cloud CLI (`gcloud`) on `PATH` identically on every platform where the profile is activated. The profile SHALL NOT log in to, configure or create any cloud account, credential, profile, region or project.

#### Scenario: Cloud CLIs are available after activation
- **WHEN** the shared home profile is activated on a supported platform
- **THEN** `aws --version`, `az version` and `gcloud --version` succeed without any additional installation step

#### Scenario: No account or credential is configured
- **WHEN** the shared home profile is activated on a host with no cloud configuration of its own
- **THEN** no AWS, Azure or Google Cloud credential, profile or default project is created, and each CLI reports that no login or configuration exists

### Requirement: Cloud port-forwarding helpers are provisioned
The shared home-manager profile SHALL provide each major cloud provider's tooling for forwarding a remote database or host port to the local machine: the Cloud SQL Auth Proxy (`cloud-sql-proxy`), the AWS Session Manager plugin (`session-manager-plugin`, used by `aws ssm start-session`), and the Azure Bastion tunnel command (`az network bastion tunnel`). The profile SHALL NOT create any tunnel, instance, bastion or jump host.

#### Scenario: Port-forwarding helpers are available after activation
- **WHEN** the shared home profile is activated on a supported platform
- **THEN** `cloud-sql-proxy --version` and `session-manager-plugin --version` succeed, and `az network bastion tunnel --help` runs without prompting to install an extension

## MODIFIED Requirements

### Requirement: Container and cloud tools are client-only
Container and cloud-related packages provisioned by this capability SHALL provide client/CLI functionality only; they SHALL NOT attempt to provide or manage the underlying runtime or service (e.g. a Kubernetes cluster or cloud account), with one exception: Docker's runtime is managed on NixOS hosts by the separate `container-runtime` capability. Outside of NixOS hosts, and for every other tool (`kubectl`, `awscli2`, `azure-cli`, `google-cloud-sdk`, `google-cloud-sql-proxy`, `ssm-session-manager-plugin`), no corresponding runtime or account is installed or managed.

#### Scenario: No runtime is installed or managed
- **WHEN** a container or cloud CLI tool other than Docker is provisioned by the shared home profile
- **THEN** no corresponding daemon, virtual machine, or account configuration is installed or managed by this capability — the tool simply connects to whatever runtime or account is already configured on the system

#### Scenario: Docker's runtime is the documented exception on NixOS
- **WHEN** the Docker CLI is provisioned by the shared home profile on a NixOS host built from this flake's shared system module
- **THEN** a Docker runtime is available via the separate `container-runtime` capability, rather than being left entirely unmanaged
