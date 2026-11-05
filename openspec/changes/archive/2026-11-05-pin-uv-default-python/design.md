# Design

## Context

`modules/home/dev-tools.nix` already sets `UV_PYTHON_PREFERENCE=only-managed` (archived change `fix-python-native-libs`). uv's selection with that setting is "newest managed interpreter satisfying `requires-python`", and 3.15 currently lacks wheels for `cffi` on aarch64.

## Goals / Non-Goals

**Goals:** a fresh `uv run` in `~/Projects/ttun-server` yields a working venv with no per-project files. **Non-Goals:** see proposal.md.

## Decisions

- **`UV_PYTHON=3.14` as a session variable**, rather than a `.python-version` in the project (the user wants the system to provide everything), a global `uv.toml` (extra managed file for the same effect), or supplying headers for source builds (heavier and fragile). An explicit `.python-version` or `--python` still overrides it, so projects can opt out.
- **Series, not patch version** (`3.14`): uv resolves to the latest managed 3.14.x, so security patch releases arrive without edits here. The series is bumped deliberately when ecosystem wheels exist for the next one.

- **Scope of the rule**: development Python comes from uv (or pyenv via the personal dotfiles), never from Nix. The Nix `python3` in `modules/home/editor.nix` stays installed for tooling (mason.nvim installers and similar packages) and is left alone; `UV_PYTHON_PREFERENCE=only-managed` already keeps uv from selecting it.

## Risks / Trade-offs

- [Projects needing 3.15+ or `requires-python` above 3.14 will fail to resolve] → They pin their own version; noted in README only if it comes up.
- [Variable is only present in new login shells] → Verification exports it explicitly or uses a fresh login shell, and checks the interpreter path.
- [Other wheel gaps surface on 3.14] → The verification runs a full `uv sync` and imports greenlet; any further failure is fixed within this change.
