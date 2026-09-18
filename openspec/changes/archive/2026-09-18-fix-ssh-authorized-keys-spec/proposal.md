## Why

The `developer-environment` capability's SSH requirement says the SSH service is "enabled... with key-based auth only," but never states that an authorized key must actually be provisioned. That gap was real: the first live NixOS host (`floep`) locked out all SSH access on first rebuild, because `PasswordAuthentication = false` was in effect with no `authorizedKeys` ever declared. The fix was applied directly to `modules/nixos/common.nix` as a live incident response, outside the OpenSpec workflow — so the spec and the implementation have been out of sync since. This change brings the spec back in line with what's actually implemented and running.

## What Changes

- `developer-environment`'s "SSH access is enabled by default on NixOS hosts" requirement is updated to state that an authorized public key MUST be provisioned for the user, and that this is what makes key-based auth actually reachable (not just theoretically configured).
- No code changes: `modules/nixos/common.nix` already declares `users.users.tom.openssh.authorizedKeys.keys`, fetched once from `https://github.com/tomvanderlee.keys` and pinned as a static literal. This change only updates the spec to describe that existing, already-verified-working behavior.

## Capabilities

### New Capabilities
(none)

### Modified Capabilities
- `developer-environment`: the SSH requirement now explicitly requires an authorized key to be provisioned, not just the service to be enabled with password auth off.

## Impact

- Affected files: `openspec/specs/developer-environment/spec.md` (via this change's delta and sync), no application code.
- Closes a real spec/implementation drift discovered after the `add-developer-environment` change was archived — the underlying fix already shipped and was verified live on the `floep` host; this change is documentation-only.
