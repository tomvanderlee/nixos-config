# Tasks

Never run `nixos-rebuild switch` without asking the user first; the user runs it themselves (it needs a sudo password). Never delete `~/Projects/ttun-server/.venv` without the user's go-ahead.

## 1. Configuration

- [x] 1.1 In `modules/home/dev-tools.nix`, remove the `UV_PYTHON` and `UV_PYTHON_PREFERENCE` `home.sessionVariables` entries and add `xdg.configFile."uv/uv.toml"` (`python-preference = "only-managed"`) and `xdg.configFile."uv/.python-version"` (`3.14`), keeping an explanatory comment; verify with `nix eval` that both files appear in `home.file`/`xdg.configFile` for `nixosConfigurations.test-vm` and `homeConfigurations."tom@linux"`
- [x] 1.2 Run `nix fmt` on the changed file and `nix flake check`; verify both pass and `git status` shows only intended files
- [x] 1.3 Build `path:/home/tom/desktop-flake#nixosConfigurations.test-vm.config.system.build.toplevel` (no switch)

## 2. Switch and verify (requires user approval)

- [x] 2.1 Show the full `git diff`, then ask the user to run `! sudo nixos-rebuild switch --flake path:/home/tom/desktop-flake#test-vm`
- [x] 2.2 After the switch, verify `~/.config/uv/uv.toml` and `~/.config/uv/.python-version` exist, and that `env -i HOME=$HOME PATH=$PATH uv python find` prints a managed 3.14 path
- [x] 2.3 Ask the user before removing the existing 3.15 `~/Projects/ttun-server/.venv`; then run `uv sync` and `uv run python -c "import greenlet; print(greenlet.__version__)"` under `env -i`; verify no `cffi` source build and the interpreter is under `~/.local/share/uv/python/cpython-3.14*`
- [x] 2.4 Fix any further failures within this change (update the artifacts first if the fix goes beyond the spec)

## Workflow follow-up

- Archive the change after review with `/opsx:archive`.
