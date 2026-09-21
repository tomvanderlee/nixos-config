## 1. Provision editor toolchain packages

- [x] 1.1 In `modules/home/editor.nix`, add `nodejs`, `python3`, and `unzip` to the
      existing `home.packages` list (alongside `tree-sitter`/`stdenv.cc`), with a
      short comment noting they're required by `mason.nvim`'s installers; verify by
      reading the file back and confirming the three entries are present.
- [x] 1.2 Verify the flake still evaluates: run `nix flake check` and confirm it
      succeeds.

## 2. Verify Mason installs succeed

- [x] 2.1 Apply the profile on an affected host (`home-manager switch --flake
      .#tom@linux` or `.#tom@darwin`, whichever is reachable) and confirm the
      activation completes without error.
- [x] 2.2 In Neovim, delete `~/.local/state/nvim/mason.log` (or run `:MasonUninstallAll`
      then reinstall), trigger installation of the previously-failing packages
      (`pyright`, `bash-language-server`, `debugpy`, `terraform-ls`,
      `yaml-language-server`, `typescript-language-server`, `css-lsp`, `html-lsp`),
      and confirm `:Mason` reports them all installed with no `npm`/`python3`/`unzip`
      "could not find executable" errors in the new log.
