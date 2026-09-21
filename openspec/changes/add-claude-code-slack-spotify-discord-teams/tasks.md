## 1. Unfree package gating

- [ ] 1.1 Create `lib/unfree-allowlist.nix` containing `[ "slack" "discord" "spotify" "claude-code" ]` and verify it evaluates with `nix eval --file lib/unfree-allowlist.nix` (or `nix-instantiate --eval`)
- [ ] 1.2 Update `lib/mkHome.nix` to construct `pkgs` via `import inputs.nixpkgs { inherit system; config.allowUnfreePredicate = pkg: builtins.elem (inputs.nixpkgs.lib.getName pkg) (import ./unfree-allowlist.nix); }` instead of `inputs.nixpkgs.legacyPackages.${system}`, and verify `nix flake show` still lists both `homeConfigurations` without error
- [ ] 1.3 Update `lib/mkNixos.nix` to prepend a module setting the same `nixpkgs.config.allowUnfreePredicate` (reusing `lib/unfree-allowlist.nix`), and verify `nix flake check` (or `nix eval .#nixosConfigurations` for any configured host) still evaluates without an "unfree package" error

## 2. Desktop applications module

- [ ] 2.1 Create `modules/home/desktop-apps.nix` with `home.packages = builtins.filter (lib.meta.availableOn pkgs.stdenv.hostPlatform) ([ pkgs.slack pkgs.discord pkgs.spotify ] ++ lib.optional pkgs.stdenv.hostPlatform.isLinux pkgs.teams-for-linux);` and verify the file evaluates standalone via `nix-instantiate --eval --strict -E 'import ./modules/home/desktop-apps.nix { pkgs = import <nixpkgs> {}; lib = (import <nixpkgs> {}).lib; }'` or equivalent
- [ ] 2.2 Add `./desktop-apps.nix` to the `imports` list in `modules/home/default.nix` and verify `home-manager build --flake .#tom@linux` and `home-manager build --flake .#tom@darwin` both evaluate successfully (run on a machine with Nix installed - not available in this environment)
- [ ] 2.3 Verify on the build output (or via `nix eval`) that `tom@darwin`'s closure excludes `teams-for-linux` while `tom@linux`'s includes it, confirming the Linux-only guard works as intended

## 3. Claude Code CLI

- [ ] 3.1 Add `pkgs.claude-code` to `modules/home/dev-tools.nix`'s `home.packages`, guarded with `lib.optional (lib.meta.availableOn pkgs.stdenv.hostPlatform pkgs.claude-code) pkgs.claude-code`, and verify `claude-code` appears on `PATH` after `home-manager build --flake .#tom@linux` (or `.#tom@darwin`) followed by activation on a machine with Nix installed

## 4. End-to-end verification

- [ ] 4.1 Run `nix flake check` on a machine with Nix installed and confirm no evaluation errors for either `homeConfigurations` entry
- [ ] 4.2 Run `statix check` and `deadnix` (already used by this repo's `devShells.default`) over the changed files and fix any findings
