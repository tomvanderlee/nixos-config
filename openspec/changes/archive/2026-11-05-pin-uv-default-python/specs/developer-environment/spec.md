# Spec Delta

## ADDED Requirements

### Requirement: uv defaults to the Python 3.14 series
The shared home profile SHALL set `UV_PYTHON=3.14` for the user so that uv's default managed interpreter is the latest 3.14.x rather than the newest available release. A project-level `.python-version` or an explicit `--python` argument SHALL continue to take precedence.

#### Scenario: A project without a pinned version gets 3.14
- **WHEN** `uv run` creates a virtual environment in a project with `requires-python = ">=3.14"` and no `.python-version`
- **THEN** the venv's interpreter is CPython 3.14.x under `~/.local/share/uv/python`

#### Scenario: Dependencies with prebuilt wheels install without source builds
- **WHEN** `uv sync` runs for `~/Projects/ttun-server` in that environment
- **THEN** it succeeds without compiling `cffi` from source and `uv run python -c "import greenlet; print(greenlet.__version__)"` prints the version
