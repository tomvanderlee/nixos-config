## 1. Verify implementation already matches the updated spec

- [x] 1.1 Confirm `modules/nixos/common.nix` declares `users.users.tom.openssh.authorizedKeys.keys` with at least one key — verify by reading the file (no code change expected; this task is a sanity check, not an implementation step) (confirmed: lines 24–26, one key present — the RSA key that remained after the earlier key removal)
