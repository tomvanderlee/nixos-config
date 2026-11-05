# Spec Delta

## MODIFIED Requirements

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
