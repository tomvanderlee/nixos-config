## 1. Verify implementation already matches the updated spec

- [ ] 1.1 Confirm `modules/nixos/common.nix` declares `users.users.tom.openssh.authorizedKeys.keys` with at least one key — verify by reading the file (no code change expected; this task is a sanity check, not an implementation step)

## 2. Sync

- [ ] 2.1 Archive this change and sync the `MODIFIED` requirement into `openspec/specs/developer-environment/spec.md` — verify the main spec's "SSH access is enabled by default on NixOS hosts" requirement includes the authorized-key sentence and the new "An authorized key is provisioned" scenario after archiving
