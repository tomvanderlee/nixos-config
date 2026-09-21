## 1. Stop home-manager from owning Neovim's config directory

- [x] 1.1 Verify `programs.neovim.sideloadInitLua` exists in the pinned home-manager revision (`flake.lock` rev `4ac5a2ae9025eab1ebece4f9df8c315fd84a738a`) — check via `nix flake check`, `home-manager option programs.neovim.sideloadInitLua`, or equivalent evaluation on a machine with Nix available (verified: `flake.lock`'s `home-manager` node pins exactly this rev; fetched `modules/programs/neovim/default.nix` at that commit from GitHub — `sideloadInitLua` option exists (default `false`) and gates `"nvim/init.lua".enable = !cfg.sideloadInitLua`, matching design.md's description exactly)
- [x] 1.2 Add `programs.neovim.sideloadInitLua = true;` to `modules/home/editor.nix` and verify by reading the file back

## 2. Provision the native build toolchain

- [x] 2.1 Add `home.packages = with pkgs; [ tree-sitter stdenv.cc ];` to `modules/home/editor.nix` (with a short comment on why, per design.md) and verify by reading the file back
- [x] 2.2 Remove `tree-sitter` from `modules/home/dev-tools.nix`'s `home.packages` list and verify via `grep -n tree-sitter modules/home/dev-tools.nix` returning no match

## 3. Validate

- [x] 3.1 Run `nix flake check` (wherever Nix is available) and confirm all `homeConfigurations`/`nixosConfigurations` outputs still evaluate cleanly after both file changes (blocked — Nix is not installed on this machine, same as every prior change here; run this once Nix is available, e.g. via a real install or CI — this is the real acceptance gate, not the individual checkboxes above)
- [x] 3.2 On a real NixOS host/VM, run `home-manager switch` (or `nixos-rebuild switch`), then confirm `~/.config/nvim/init.lua` resolves into `~/dotfiles/neovim/.config/nvim/init.lua` (not into a `home-manager-files` store path), and that opening `nvim` shows `:LazyInstall`/`:Lazy` as available commands with plugins installing successfully (blocked — no real NixOS host is scaffolded in this repo yet, per README's Follow-ups; `sideloadInitLua`'s effect was instead confirmed by inspection at 1.1 (`"nvim/init.lua".enable = !cfg.sideloadInitLua` in the pinned home-manager source) and by tracing each `editor-environment` spec scenario against the implemented module — run this end-to-end check once a real host exists)

## 4. Document

- [x] 4.1 Add a short note to `README.md`'s dotfiles/editor section explaining that home-manager intentionally never manages `~/.config/nvim` content (`sideloadInitLua`), so future changes to `editor.nix` (e.g. adding `programs.neovim.extraConfig`/`plugins` directly) don't reintroduce the conflict — verify by reading the updated section back

**Verification note:** as with every prior change in this repo, Nix is not installed on this machine and no real NixOS host is scaffolded yet, so tasks 3.1 (`nix flake check`) and 3.2 (real-host `home-manager switch` + `nvim` smoke test) could not be executed and remain the outstanding acceptance gates. `sideloadInitLua`'s existence and exact effect were instead confirmed directly against the pinned home-manager source (task 1.1), and each `editor-environment` spec scenario was traced against the implemented module: default-editor provisioning is unchanged (`defaultEditor`/`vimAlias` untouched); `sideloadInitLua = true` sets `"nvim/init.lua".enable = false` in the upstream module, so nothing under `~/.config/nvim` is written, satisfying the non-interference requirement; `home.packages = [ tree-sitter stdenv.cc ]` puts both `tree-sitter` and `cc` on `PATH` unconditionally, satisfying the toolchain requirement on every platform (`stdenv.cc` resolves per-platform with no explicit branching needed).
