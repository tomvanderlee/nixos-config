## Purpose

Provisions the developer's most-used CLI/client tooling through the shared home-manager profile and enables common baseline system services, such as SSH access, on every NixOS host built from this flake.

## Requirements

### Requirement: Developer CLI tools are provisioned via the shared home profile
The shared home-manager profile SHALL include the user's evidenced most-used CLI and client tools, available identically wherever that profile is activated (standalone or via a NixOS host).

#### Scenario: Tooling available after activation
- **WHEN** the shared home profile is activated on any supported platform
- **THEN** the provisioned developer CLI tools are available on `PATH` without any additional manual installation step

### Requirement: Container and cloud tools are client-only
Container and cloud-related packages provisioned by this capability SHALL provide client/CLI functionality only and SHALL NOT provide or manage the underlying runtime or service (such as a Kubernetes cluster or cloud account), except for Docker's runtime on NixOS hosts, which the separate `container-runtime` capability manages.

#### Scenario: No runtime is installed or managed
- **WHEN** a container or cloud CLI tool other than Docker (`kubectl`, `awscli2`, `azure-cli`, `google-cloud-sdk`, `google-cloud-sql-proxy`, `ssm-session-manager-plugin`) is provisioned by the shared home profile
- **THEN** no corresponding daemon, virtual machine, or account configuration is installed or managed by this capability — the tool simply connects to whatever runtime or account is already configured on the system

#### Scenario: Docker's runtime is the documented exception on NixOS
- **WHEN** the Docker CLI is provisioned by the shared home profile on a NixOS host built from this flake's shared system module
- **THEN** a Docker runtime is available via the separate `container-runtime` capability, rather than being left entirely unmanaged

### Requirement: Shell and prompt configuration defers to the user's personal dotfiles
Where the user's personal dotfiles repository already owns a piece of shell or prompt configuration, the shared home profile SHALL provide only the underlying package, not a competing managed configuration for that same file.

#### Scenario: Prompt tool provisioned without managed config
- **WHEN** the shared home profile provisions a prompt tool whose configuration is already owned by the user's dotfiles repository
- **THEN** the profile installs the tool's package but does not generate or manage a competing configuration file for it

### Requirement: SSH access is enabled by default on NixOS hosts
Every NixOS host built from this flake's shared system module SHALL have an SSH server enabled, with password authentication and root login disabled, and SHALL permit inbound SSH traffic through its firewall. The system SHALL also provision at least one authorized public key for the user, so that key-based authentication is actually reachable rather than merely configured.

#### Scenario: SSH reachable with key-based auth only
- **WHEN** a NixOS host is built from the shared system module
- **THEN** the SSH service is enabled, password authentication and root login are disabled, and the firewall permits inbound connections on the SSH port

#### Scenario: An authorized key is provisioned
- **WHEN** a NixOS host is built from the shared system module
- **THEN** the user account has at least one authorized public key configured, so a matching private key can actually authenticate over SSH

### Requirement: The openssl command is provisioned
The shared home-manager profile SHALL provide the `openssl` command-line tool on `PATH`, identically on every platform where the profile is activated.

#### Scenario: openssl is available after activation
- **WHEN** the shared home profile is activated on a supported platform
- **THEN** `openssl version` runs successfully without any additional installation step

### Requirement: uv uses its own managed Python interpreters
The shared home profile SHALL configure uv, through its user config file `~/.config/uv/uv.toml` (`python-preference = "only-managed"`), so that uv never selects a Nix-built `python3` from `PATH`. The setting SHALL NOT depend on environment variables or shell startup files. The Nix `python3` package remains installed for tools that need it.

#### Scenario: A project venv is created with a managed interpreter
- **WHEN** `uv run` or `uv sync` creates a virtual environment for a project with no `.python-version`, in a shell with no `UV_*` variables set
- **THEN** the venv's interpreter resolves under uv's managed Python directory and not to a `/nix/store` path

#### Scenario: Native wheels with C++ dependencies import in that venv
- **WHEN** `uv run python -c "import greenlet; print(greenlet.__version__)"` is run in a project depending on greenlet
- **THEN** it prints the version instead of failing with `libstdc++.so.6: cannot open shared object file`

### Requirement: uv defaults to the Python 3.14 series
The shared home profile SHALL write `~/.config/uv/.python-version` containing `3.14` so that uv's default managed interpreter is the latest 3.14.x rather than the newest available release. The default SHALL NOT depend on environment variables or shell startup files. A project-level `.python-version` or an explicit `--python` argument SHALL continue to take precedence.

#### Scenario: A project without a pinned version gets 3.14 in a clean environment
- **WHEN** `env -i HOME=$HOME PATH=... uv sync` runs in a project with `requires-python = ">=3.14"` and no `.python-version`
- **THEN** the venv's interpreter is CPython 3.14.x under `~/.local/share/uv/python`

#### Scenario: Dependencies with prebuilt wheels install without source builds
- **WHEN** `uv sync` runs for `~/Projects/ttun-server` in that environment
- **THEN** it succeeds without compiling `cffi` from source and `uv run python -c "import greenlet; print(greenlet.__version__)"` prints the version

### Requirement: The WireGuard command-line tools are provisioned
The shared home-manager profile SHALL provide the `wg` and `wg-quick` commands on `PATH`, identically on every platform where the profile is activated, for inspecting and manually managing WireGuard tunnels. The profile SHALL NOT create or configure any WireGuard interface, peer, key or firewall rule.

#### Scenario: WireGuard tools are available after activation
- **WHEN** the shared home profile is activated on a supported platform
- **THEN** `wg --version` and `command -v wg-quick` succeed without any additional installation step

#### Scenario: No tunnel is configured
- **WHEN** the shared home profile is activated on a host with no WireGuard configuration of its own
- **THEN** no WireGuard interface, peer or key is created, and `sudo wg show` lists no interfaces

### Requirement: The major cloud providers' command-line tools are provisioned
The shared home-manager profile SHALL provide the AWS CLI (`aws`), the Azure CLI (`az`) and the Google Cloud CLI (`gcloud`) on `PATH`, identically on every platform where the profile is activated. The profile SHALL NOT log in to, configure or create any cloud account, credential, profile, region or project.

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
