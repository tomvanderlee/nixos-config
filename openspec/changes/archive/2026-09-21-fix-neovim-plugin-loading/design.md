## Context

See proposal.md - Why. `modules/home/editor.nix` currently only sets `programs.neovim = { enable = true; defaultEditor = true; vimAlias = true; }`. Root cause investigation (confirmed against home-manager's upstream source, `modules/programs/neovim/default.nix`, pinned at `flake.lock` rev `4ac5a2ae9025eab1ebece4f9df8c315fd84a738a`) establishes:

- `programs.neovim.enable = true` always makes `cfg.initLua` non-empty, via `wrappedNeovim'.luaRcContent` (nixpkgs' `wrapNeovimUnstable` packpath/rtp plumbing) — regardless of whether `plugins`/`extraConfig` are set.
- That non-empty `cfg.initLua` is unconditionally written to `xdg.configFile."nvim/init.lua"` unless `programs.neovim.sideloadInitLua = true`, which is the module's documented escape hatch: "avoid writing the content of `initLua` to the default location `$XDG_CONFIG_HOME/nvim/init.lua` and load it through neovim wrapper arguments instead." A home-manager test (`tests/modules/programs/neovim/no-init-lua.nix`) confirms `init.lua`/`init.vim` are not created under `home-files` when it's set.
- `modules/home/dotfiles.nix`'s `home.activation.dotfiles` script runs `stow -d ~/dotfiles -t $HOME <pkg>` after home-manager's own file-linking (`entryAfter [ "writeBoundary" ]`), so by the time it tries to link the `neovim` package, home-manager has already placed its own file at `~/.config/nvim/init.lua`. Stow (no `--adopt` in this script) treats that as a foreign conflict and skips the whole package (per `dotfiles-management`'s existing per-package skip-on-conflict requirement) — so none of the real config, including the lazy.nvim bootstrap, ever gets linked.
- Separately, no `home.packages`/`environment.systemPackages` list anywhere in this repo includes a C compiler (confirmed by repo-wide grep), which would block natively-built plugins (e.g. nvim-treesitter parser compilation via the `tree-sitter` CLI already provided in `modules/home/dev-tools.nix`) once the config above actually loads.

## Goals / Non-Goals

**Goals:**
- Eliminate the file-ownership conflict deterministically, for every activation, on every platform this flake builds — not a race/ordering workaround.
- Keep `defaultEditor`/`vimAlias`/package wrapping behavior unchanged.
- Provision what natively-built plugins need to compile, without hand-picking a compiler per platform.

**Non-Goals:**
- Modifying the external `~/dotfiles` repository or its Neovim/lazy.nvim configuration — out of scope, owned by the user outside this flake.
- Automating plugin installation itself — lazy.nvim already does this on its own once its config loads; no change needed here.
- Hardening `modules/home/dotfiles.nix`'s git-clone step (network/timing robustness) — a distinct concern from this change's root cause, left as a candidate future change.
- Adding `gnumake` or other build tools speculatively — no plugin in the current dotfiles config needs anything beyond a C compiler and the `tree-sitter` CLI (verified: only `treesitter.lua` declares a `build` step, and it's Lua-driven via `:TSUpdate`, not `make`-driven).

## Decisions

**Use `programs.neovim.sideloadInitLua = true` rather than any Stow-side workaround.** Alternatives considered: passing `--adopt` to Stow (rejected — this is exactly the manual action that corrupted the user's live `~/dotfiles` checkout by overwriting the real tracked file with a symlink; it treats the symptom, not the cause, and remains a race depending on which side runs first); excluding the `neovim` Stow package on NixOS (rejected — defeats the purpose, the user wants their real config linked); dropping `programs.neovim` entirely in favor of a bare `home.packages = [ pkgs.neovim ]` plus hand-rolled `EDITOR`/`vim` alias (rejected — more code, reinvents what `sideloadInitLua` already solves as a one-line, first-class, documented option). `sideloadInitLua` is a built-in, purpose-made escape hatch for exactly this ownership conflict.

**Use `pkgs.stdenv.cc` for the compiler, not `pkgs.gcc`/`pkgs.clang` directly.** `stdenv.cc` resolves to each platform's default compiler wrapper (gcc-wrapper on Linux, clang-wrapper on Darwin) with no `pkgs.stdenv.isDarwin` branching, and avoids forcing nixpkgs' GCC through its notoriously heavy Darwin bootstrap path. This also mirrors what the dotfiles config already implicitly depended on (Xcode Command Line Tools' `clang`) on macOS, now provided reproducibly by Nix instead of an out-of-band Xcode install.

**Co-locate `tree-sitter` and the compiler in `editor.nix`, moving `tree-sitter` out of `dev-tools.nix`.** Both packages exist solely to let Neovim's plugins build; `dev-tools.nix` is a grab-bag of independently-useful CLI tools (`gh`, `docker`, `kubectl`, ...). Grouping build-time editor dependencies in `editor.nix` keeps that file's purpose ("everything the shared profile provisions so the externally-managed Neovim config fully works") self-documenting.

**New `editor-environment` capability rather than extending `developer-environment`.** `developer-environment`'s existing scope (per its spec overview) is general CLI/client tooling and SSH; `editor.nix` has never had spec coverage. `developer-environment`'s requirement #3 ("Where the user's personal dotfiles repository already owns a piece of shell or prompt configuration, the shared home profile SHALL provide only the underlying package...") already establishes the identical principle for shell/prompt — `editor-environment` extends that same precedent to Neovim specifically, rather than stretching `developer-environment`'s stated scope to cover it.

## Risks / Trade-offs

- [`sideloadInitLua` might not exist in the exact pinned home-manager revision if upstream added it very recently] → Verify during implementation (task in tasks.md) by evaluating the flake or checking `home-manager option programs.neovim.sideloadInitLua` before relying on it; confirmed present on upstream `master` as of this investigation, which the pin (dated ~2026-09) closely tracks.
- [A future plugin added to the externally-managed dotfiles config needs `make` or another native build tool not provisioned here] → Out of this change's control (external repo); a one-line follow-up addition to `editor.nix`'s `home.packages` if/when it happens.
- [The user's live `~/dotfiles` checkout still has `neovim/.config/nvim/init.lua` overwritten by a stray symlink from a prior manual `stow --adopt`] → Not fixed by this change (outside this repo); the user needs to run `git checkout -- neovim/.config/nvim/init.lua` in `~/dotfiles` independently.

## Migration Plan

No data migration. Deploy by merging the `editor.nix`/`dev-tools.nix` changes and running `home-manager switch` (or `nixos-rebuild switch`) as normal on each host; the next activation both stops writing the conflicting file and adds the new packages in one step. Rollback is a plain revert of the same two files.
