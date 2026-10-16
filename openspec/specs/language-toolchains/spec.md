# language-toolchains Specification

## Purpose

Provisions Go and Rust development toolchains through the shared home-manager profile so that building, formatting, linting and editing Go and Rust code works on any machine that activates the profile, without manual installs.

## Requirements

### Requirement: Go toolchain is provisioned
The shared home-manager profile SHALL provide the Go compiler and `go` command and the `gopls` language server on `PATH`.

#### Scenario: Go project builds after activation
- **WHEN** the shared home profile is activated on a supported platform
- **THEN** `go version` and `gopls version` run successfully and `go build` can compile a Go module without further installation

### Requirement: Rust toolchain is provisioned
The shared home-manager profile SHALL provide `cargo`, `rustc`, `rustfmt`, `clippy` (`cargo clippy`) and `rust-analyzer` on `PATH`.

#### Scenario: Rust project builds and lints after activation
- **WHEN** the shared home profile is activated on a supported platform
- **THEN** `cargo build`, `cargo fmt`, `cargo clippy` and `rust-analyzer --version` all run successfully without further installation

### Requirement: Toolchains are available on every supported platform
The Go and Rust toolchains SHALL be provisioned for both standalone home-manager activations and NixOS hosts, on Linux and macOS, and SHALL NOT require NixOS-specific configuration.

#### Scenario: Standalone activation evaluates
- **WHEN** `homeConfigurations."tom@linux"` or `"tom@darwin"` is evaluated
- **THEN** evaluation succeeds and the resulting package set contains the Go and Rust toolchain packages

### Requirement: Toolchain provisioning does not manage editor configuration
This capability SHALL provide only the toolchain packages and SHALL NOT generate or manage any Neovim configuration, or set `GOPATH`, `CARGO_HOME` or similar environment variables.

#### Scenario: No competing configuration is generated
- **WHEN** the shared home profile provisions the toolchains
- **THEN** no file under `~/.config/nvim` is written by this capability, and the dotfiles repository remains the sole owner of editor configuration
