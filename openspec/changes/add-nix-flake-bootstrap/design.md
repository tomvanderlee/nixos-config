## Context

See proposal.md - Why. The repo is empty of Nix config; this design establishes the first module layout, so the choices below aren't tweaks to an existing architecture, they're the starting shape everything else builds on. Development happens on macOS (glootie), but glootie has no Nix installed and is not a target host in this change — so nothing here can be locally exercised on real hardware except through `nix flake check` / building `homeConfigurations."tom@linux"`.

## Goals / Non-Goals

**Goals:**
- Prove that one module (`users/tom.nix`) drives identical behavior through two different activation mechanisms (NixOS's home-manager module, standalone home-manager).
- Keep the flake's outputs buildable and checkable today, with zero real hardware and zero remote.
- Make the "add a real host" path (copy template → drop in generated hardware config → add flake output) mechanical, not something requiring new code.

**Non-Goals:**
- Building a real, live host of any kind (NixOS or darwin) — only the template and the standalone `tom@linux` output are real in this change.
- Declarative disk partitioning, secrets management, or multi-host auto-discovery — all explicitly deferred (see proposal.md - Impact).

## Decisions

**Plain `flake.nix` + `lib/` helpers, not flake-parts.** flake-parts reduces boilerplate once a flake has many perSystem outputs across many systems, but this flake has exactly one target system per output type initially. A framework input that isn't earning its keep yet is the kind of extra surface this project is trying to avoid. Revisit if the outputs section grows unwieldy.

**`hosts/template/` is never wired into `nixosConfigurations`.** The alternative — exposing `nixosConfigurations.template` so `nix flake check` exercises it — was rejected because its `hardware-configuration.nix` can only be made to build by inventing plausible-looking `fileSystems` entries for hardware that doesn't exist, which is fabricating success rather than validating anything. Leaving it unwired is honest about what is and isn't tested.

**nix-darwin is not added as a flake input in this change.** An input with no output exercising it is dead weight in the lockfile, and it can't be evaluated meaningfully — glootie has no Nix installed, so there's no way to build or activate a darwin config here even experimentally. Bringing it in now would not actually strengthen the "shared module" claim, since that claim is already demonstrated by two *real* consumers of `modules/home` (`nixosConfigurations` path via home-manager's NixOS module, and the standalone `homeConfigurations."tom@linux"` output). Add nix-darwin in the follow-up change that configures a real Mac host, when it can be tested for real. Same reasoning applies to `nixos-hardware` (no known hardware yet).

**Determinate Systems installer recommended for standalone Nix installs (documentation only, not enforced in code).** It enables flakes by default, avoiding a manual `nix.conf` edit — one less manual step that would otherwise need documenting as a "first, do this hack." The official installer remains a valid alternative and is noted in the README as such.

**`modules/home/*` stays flat, no `linux/`/`darwin/` subdirectories yet.** The only divergence needed today is handled inline with `lib.mkIf pkgs.stdenv.isLinux` / `isDarwin` in individual module files. Splitting into per-OS directories now would structure for divergence that doesn't exist yet (there is no darwin consumer at all in this change).

**No default `stateVersion` in the `mkNixos`/`mkHome` helpers.** A shared default would silently paper over the fact that this value must reflect the release actually in use at install time for each specific host/user — baking one in is the kind of hidden default that causes real (if usually minor) breakage later. Requiring it explicitly per host/user is the standard, non-hack idiom.

## Risks / Trade-offs

- **No remote to clone from during a real NixOS install** → Mitigation: documented as an explicit prerequisite in the README and flagged as follow-up work in the proposal; not something this change can solve since it depends on the user's choice of remote host.
- **No way to locally validate `nixosConfigurations` behavior (no NixOS host exists, and even the template is deliberately unbuilt)** → Mitigation: `nix flake check` still validates `lib`, `homeConfigurations."tom@linux"`, `formatter`, and `devShells`; NixOS-path validation is deferred to when a real host is added, at which point that host's build is the test.
- **Determinate Systems installer is a third-party tool, not the official NixOS project installer** → Mitigation: documented as a recommendation with the official installer named as a fallback, so the choice is visible and reversible, not baked into any script.
- **Flat `modules/home/` with inline `mkIf` branches could get noisy if darwin-specific config grows later** → Mitigation: acceptable now since there are zero darwin branches; the design explicitly allows splitting into per-OS directories in a later change once real divergence exists, rather than pre-building structure for it.

## Open Questions

- Whether to install bare Nix (package manager only, no activation) on glootie purely to enable local `nix flake check`/`nix build` validation ahead of a real install elsewhere, versus relying on CI once the repo has a remote. Deferring this doesn't change the specs, the module layout, or the task breakdown for this change — it only affects how validation is performed, and can be decided later.
