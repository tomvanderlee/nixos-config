# Spec Delta

## ADDED Requirements

### Requirement: uv uses its own managed Python interpreters
The shared home profile SHALL set `UV_PYTHON_PREFERENCE=only-managed` for the user so that uv never selects a Nix-built `python3` from `PATH`. The Nix `python3` package remains installed for tools that need it.

#### Scenario: A project venv is created with a managed interpreter
- **WHEN** `uv run` or `uv sync` creates a virtual environment for a project with no `.python-version`
- **THEN** the venv's interpreter resolves under uv's managed Python directory and not to a `/nix/store` path

#### Scenario: Native wheels with C++ dependencies import in that venv
- **WHEN** `uv run python -c "import greenlet; print(greenlet.__version__)"` is run in a project depending on greenlet
- **THEN** it prints the version instead of failing with `libstdc++.so.6: cannot open shared object file`
