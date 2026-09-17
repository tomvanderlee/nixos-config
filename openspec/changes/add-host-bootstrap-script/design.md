## Context

See proposal.md - Why. The `add-nix-flake-bootstrap` change already put `hosts/template/`, `lib/mkNixos.nix`, and a hardcoded empty `nixosConfigurations = { };` in place; this change replaces the "hand-copy the template, hand-edit `flake.nix`" workflow with a script and a directory-driven flake output. Nix is still not installed on this development machine, so nothing here can be locally evaluated or run — same constraint as the prior change.

## Goals / Non-Goals

**Goals:**
- Make `flake.nix` require zero edits when a new NixOS host is added — dropping a correctly-shaped directory under `hosts/` is sufficient.
- Make it structurally impossible for the script to default to reading the invoking environment's own `/etc/nixos` — the root must always be named explicitly by the caller.
- Keep the script a plain, auditable shell script wrapped as a flake app, not a new categorically different tool.

**Non-Goals:**
- Driving `nixos-install`/`nixos-rebuild` itself (confirmed: scaffold only).
- Any scaffolding for non-NixOS/standalone hosts (confirmed: `homeConfigurations."tom@linux"` stays generic).
- Mountpoint auto-detection or any other heuristic for guessing the root path (confirmed: always an explicit flag).

## Decisions

**`nixosConfigurations` becomes directory-driven (`builtins.readDir ./hosts` + per-host `system` file) instead of a hand-maintained attrset.** The alternative — having the script parse and rewrite `flake.nix` text to insert a new `nixosConfigurations.<name> = lib.mkNixos {...};` line — was rejected as fragile: it requires the script to locate the right insertion point, preserve formatting the `nixfmt` formatter would otherwise enforce, and handle the case of the attrset already containing entries. Reading the `hosts/` directory structure is declarative and needs no generated/edited Nix source at all, which is both simpler and more idiomatic. The cost is one small new per-host file (`system`, a bare string, no trailing newline) that didn't exist before; `hosts/template/system` gets one too so the template stays a complete, consistent copy-source, though it's still excluded from discovery by name exactly as the template's other files already are.

**Root path is a required flag, not detected.** Considered auto-detecting via `mountpoint -q /mnt` (the most common real-world case). Rejected per explicit user decision: an explicit `--root` on every invocation is a stronger, simpler guarantee against the exact failure mode being guarded against (reading the live ISO's own `/etc/nixos`) than any heuristic, at the cost of one extra flag to type.

**Hardware config is read from `<root>/etc/nixos/hardware-configuration.nix`, generating it via `nixos-generate-config --root <root>` if absent and the command is available.** This mirrors the existing manual workflow's own use of `nixos-generate-config --root /mnt` (see the prior change's README), just invoked by the script instead of by hand. `nixos-generate-config` is not added as a nixpkgs runtime dependency of the wrapped app — it's inherently an ambient NixOS system tool tied to whichever NixOS the script is currently running under (live ISO or an installed system), not a standalone package to vendor; the script fails clearly if it's both missing and no pre-existing hardware config is found at the root.

**Script stays a plain file (`scripts/bootstrap-host.sh`) wrapped by `pkgs.writeShellApplication`, not inlined into `flake.nix`.** Keeps the logic readable and diffable as ordinary shell, while `writeShellApplication` gives shellcheck validation and a clean `PATH` when exposed as `apps.<system>.bootstrap-host` — avoids both "raw unvalidated bash" and "logic buried inside deeply-nested Nix string interpolation."

**`--state-version` has no default, matching the existing project-wide rule** (from the prior change's design) that `stateVersion` must never be silently defaulted by tooling, since it must reflect the actual release in use at install time for that specific host.

## Risks / Trade-offs

- **Adding a `hosts/<name>/system` file is a new convention with no precedent elsewhere in the repo** → Mitigation: it's the smallest possible mechanism (one line, no Nix syntax) and is documented in the updated README alongside the rest of the host-creation flow.
- **No local way to test that `builtins.readDir`-based discovery actually evaluates correctly, or that the script's shell logic is fully correct, since Nix isn't installed here** → Mitigation: same as the prior change — careful manual construction plus shellcheck-level self-review now, full `nix flake check` / actually running the script deferred until Nix is available (real install or CI). This is the real acceptance gate, not any individual task checkbox.
- **This change's spec delta targets the same `nix-flake-bootstrap` capability path as the still-unarchived `add-nix-flake-bootstrap` change** → Mitigation: uses `ADDED Requirements` only (no `MODIFIED`), so the two changes' deltas are purely additive and don't conflict regardless of archive order.
