# Tasks

Never run `nixos-rebuild switch` without asking the user first; the user runs it themselves (it needs a sudo password). Show the full diff before asking.

## 1. Configuration

- [x] 1.1 Add `UV_PYTHON = "3.14";` to `home.sessionVariables` in `modules/home/dev-tools.nix` next to `UV_PYTHON_PREFERENCE`; verify via `nix eval` on `nixosConfigurations.test-vm.config.home-manager.users.tom.home.sessionVariables` and `homeConfigurations."tom@linux"`
- [x] 1.2 Run `nix fmt` on the changed file and `nix flake check`; verify both pass and `git status` shows only intended files
- [x] 1.3 Build `path:/home/tom/desktop-flake#nixosConfigurations.test-vm.config.system.build.toplevel` (no switch)

## 2. Switch and verify (requires user approval)

- [x] 2.1 Show the full `git diff`, then ask the user to run `! sudo nixos-rebuild switch --flake path:/home/tom/desktop-flake#test-vm`
- [x] 2.2 After the switch, in a fresh login-shell environment (or with the variables exported), check `~/Projects/ttun-server/.venv` is absent, then run `uv sync` there; verify it succeeds without building `cffi` from source
- [x] 2.3 Run `uv run python -c "import greenlet; print(greenlet.__version__)"`; verify it prints a version and `readlink -f .venv/bin/python` is under `~/.local/share/uv/python/cpython-3.14*`
- [x] 2.4 Fix any further failures found in 2.2 or 2.3 within this change (update the artifacts first if the fix goes beyond the spec)

## Workflow follow-up

- Archive the change after review with `/opsx:archive`.
