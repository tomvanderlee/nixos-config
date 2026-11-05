# Tasks

Never run `nixos-rebuild switch` or `home-manager switch` without asking the user first. Show the full diff before asking.

## 1. Configuration

- [ ] 1.1 Record `path:/home/tom/desktop-flake#nixosConfigurations.test-vm.config.system.build.toplevel.drvPath` for later comparison
- [x] 1.2 Add `UV_PYTHON_PREFERENCE = "only-managed"` to `home.sessionVariables` in the home module owning developer tooling; verify via `nix eval` on both `nixosConfigurations.test-vm.config.home-manager.users.tom.home.sessionVariables` and `homeConfigurations."tom@linux"`
- [x] 1.3 Add `stdenv.cc.cc.lib`, `zlib`, `libuuid`, `libxcrypt-legacy` to `programs.nix-ld.libraries` in `modules/nixos/common.nix`; verify the evaluated list contains them and the original six remain

## 2. Checks

- [x] 2.1 Run `nix fmt` (bare invocation errors in this repo with nixfmt "unexpected end of input"; ran it on the changed files instead) and `nix flake check`; verify both pass and `git status` shows only intended files
- [x] 2.2 Build `path:/home/tom/desktop-flake#nixosConfigurations.test-vm.config.system.build.toplevel` (no switch) and verify `nix-ld/lib` in the result contains `libstdc++.so.6`, `libz.so.1`, `libuuid.so.1`, `libcrypt.so.1`

## 3. Switch and verify (requires user approval)

- [x] 3.1 Show the full `git diff` with rationale, then ask before switching
- [x] 3.2 After the approved switch, ask before recreating the venv in `~/Projects/ttun-server` (removes `.venv`), then run `uv run python -c "import greenlet; print(greenlet.__version__)"`; on failure inspect with `LD_DEBUG=libs` before adding libraries
  - Result: verified in a throwaway venv (user declined deleting `.venv`); managed 3.14.9 printed greenlet 3.5.3. Note: without a pin uv picks managed 3.15, which lacks cffi wheels, so the project needs `.python-version` or `--python 3.14`.
- [x] 3.3 Verify the venv interpreter resolves under `~/.local/share/uv/python`, not `/nix/store`

## Workflow follow-up

- Archive the change after review with `/opsx:archive`.
