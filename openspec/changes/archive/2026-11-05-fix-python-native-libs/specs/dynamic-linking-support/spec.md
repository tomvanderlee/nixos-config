# Spec Delta

## ADDED Requirements

### Requirement: The nix-ld library set explicitly includes the C++ runtime and zlib
The shared system module SHALL list `stdenv.cc.cc.lib` (providing `libstdc++.so.6`) and `zlib` in `programs.nix-ld.libraries` explicitly, together with `libuuid` and `libxcrypt-legacy`, so that foreign binaries needing them load regardless of nix-ld's built-in defaults.

#### Scenario: The nix-ld library directory contains the explicit libraries
- **WHEN** a host built from this flake is evaluated
- **THEN** its `programs.nix-ld.libraries` includes `stdenv.cc.cc.lib` and `zlib`, and the built `nix-ld/lib` directory contains `libstdc++.so.6`, `libz.so.1`, `libuuid.so.1` and `libcrypt.so.1`

#### Scenario: A prebuilt C++ native wheel loads under a managed interpreter
- **WHEN** a uv-managed Python imports a wheel whose extension links against `libstdc++.so.6` (for example `greenlet`)
- **THEN** the import succeeds
