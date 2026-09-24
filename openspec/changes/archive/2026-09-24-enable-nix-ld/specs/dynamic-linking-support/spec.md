## Purpose

Lets NixOS hosts built from this flake run prebuilt, foreign (non-Nix-built) dynamically-linked binaries — such as the interpreters and native wheel extensions that developer tools like `uv` fetch at runtime — instead of failing with a missing-interpreter execution error.

## ADDED Requirements

### Requirement: NixOS hosts run foreign dynamically-linked binaries via nix-ld
Every NixOS host built from this flake's shared system module SHALL enable `nix-ld`, so that prebuilt binaries linked against a standard (non-NixOS) dynamic loader path execute correctly instead of failing to run.

#### Scenario: A uv-managed prebuilt Python interpreter executes
- **WHEN** `uv python install` downloads a prebuilt CPython interpreter and that interpreter is invoked
- **THEN** the interpreter starts successfully instead of failing with a missing-interpreter or "cannot execute binary file" error

#### Scenario: A native wheel extension loads its shared library dependencies
- **WHEN** a Python package installed by `uv` includes a prebuilt native (C-extension) binary that depends on common shared libraries (e.g. `ncurses`, `libffi`, `sqlite`, `readline`, `gdbm`, `expat`, or another library covered by `nix-ld`'s configured library set)
- **THEN** the extension loads its dependencies successfully instead of failing with a missing shared library error

### Requirement: The nix-ld library set is host-wide and additive
The set of libraries made available to foreign binaries via `nix-ld` SHALL be defined once for all NixOS hosts built from this flake's shared system module, and SHALL be extensible by appending further libraries without removing or replacing the existing set.

#### Scenario: A host-level addition does not remove existing libraries
- **WHEN** a NixOS host's own configuration adds an additional library to the nix-ld library set
- **THEN** the libraries already provided by the shared system module remain available, unaffected by the addition
