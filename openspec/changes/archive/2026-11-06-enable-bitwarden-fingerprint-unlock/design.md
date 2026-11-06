# Design

## Context

Bitwarden desktop is installed per user via home-manager. On NixOS, polkit reads action policies from `/run/current-system/sw/share/polkit-1/actions` (`/share/polkit-1` is in `environment.pathsToLink`), not from per-user profiles. `security.polkit.enable` is already true through the GNOME module, and fprintd's module turns on `fprintAuth` for every PAM service including `polkit-1`.

## Goals / Non-Goals

**Goals:** make Bitwarden's "Unlock with system authentication" work with the fingerprint on the ThinkPad. **Non-Goals:** see proposal.md.

## Decisions

- **Add `pkgs.bitwarden-desktop` to the host's `environment.systemPackages`** instead of only enabling polkit, because the missing piece is the policy file's location, not the polkit daemon. Alternative: `security.polkit.extraConfig` rules. Rejected; the stock policy already defines the action.
- **Set `security.polkit.enable = true` explicitly** at the user's request, even though GNOME already enables it; the value is unchanged and the dependency is documented.
- **Host-level, not `common.nix`**, matching where fprintd is enabled, so hosts without a reader are unchanged.

## Risks / Trade-offs

- [Two Bitwarden copies on the system path and in the user profile] → Same store path, since both come from the same `pkgs`, so no extra build or disk use.
- [Option stays hidden in Bitwarden if the policy still isn't found] → Verify after rebuild with `pkaction --verbose --action-id com.bitwarden.Bitwarden.unlock`.
