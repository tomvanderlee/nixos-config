## Context

See proposal.md - Why. This extends `modules/nixos/common.nix` from `add-nix-flake-bootstrap` (already carrying flakes/gc/locale/user/ssh/firewall settings applied to every NixOS host) with a desktop environment. Confirmed via direct Q&A: GNOME applies unconditionally to every NixOS host, not as an opt-in per-host module — every NixOS machine this flake provisions is meant to be a desktop. Nix is still not installed on this development machine, so nothing here can be locally evaluated.

## Goals / Non-Goals

**Goals:**
- A NixOS host built from this flake boots directly into a usable GNOME desktop: login, networking, audio, and printing all work without additional manual setup.
- Keep the addition to the already-established `modules/nixos/common.nix` pattern — no new module file needed, since this applies universally like the rest of that file's contents.

**Non-Goals:**
- Per-user GNOME customization (dconf settings, GNOME Shell extensions via home-manager) — a system-level toggle only.
- Any change to the user's `~/dotfiles` `herbstluftwm`/`xorg` packages or the dotfiles-stow automation (`add-dotfiles-stow-bootstrap`) — unrelated; that repo's tiling-WM configuration is untouched.
- Fully removing Xorg/XWayland from the system. GDM defaults to a Wayland GNOME session already; XWayland (X11-app compatibility) and an optional Xorg fallback session remain present as standard NixOS/GNOME infrastructure — not something this change attempts to strip out.

## Decisions

**Added directly to `modules/nixos/common.nix`, not a separate opt-in module.** Per the user's explicit choice, GNOME applies to every NixOS host unconditionally — the same scope as everything else already in that file (flakes, ssh, firewall, gc policy). A separate `modules/nixos/desktop-gnome.nix` that hosts import individually was considered and rejected specifically because the user wants it universal, not per-host.

**NetworkManager, PipeWire, and printing/Avahi are included as necessary companions, not scope creep.** A GNOME desktop without working networking, audio, or discoverable printers would only be partially functional:
- `networking.networkmanager.enable = true` — GNOME's Settings → Network and the top-bar network menu are built against NetworkManager; without it they don't work.
- `services.pipewire.enable` + `pulse.enable`, plus `security.rtkit.enable` — the current standard NixOS audio stack GNOME expects, including PulseAudio-compatible clients.
- `services.printing.enable` (CUPS) + `services.avahi` (`nssmdns4`, `openFirewall`) — printing was explicitly requested; Avahi is included alongside it so network/AirPrint-style printers are actually discoverable rather than requiring manual IP-based setup. `openFirewall = true` specifically because `add-developer-environment` already enabled `networking.firewall` with only port 22 allowed — without this, printer discovery (mDNS) traffic would be silently blocked by that firewall.

**Module option paths used reflect NixOS's current (post-migration) namespace, flagged as an implementation-time risk.** NixOS has been moving `services.xserver.displayManager.*` / `services.xserver.desktopManager.*` into standalone `services.displayManager.*` / `services.desktopManager.*`. The design uses the newer paths as pinned to `nixos-unstable`, consistent with this repo's existing pattern of flagging package/option-naming uncertainty explicitly (`yq-go` vs `yq`, `terraform`'s licensing) rather than asserting confidently what can't be verified locally. If evaluation fails once Nix is available, the fallback is the older nested paths under `services.xserver.*`.

**Wayland is the default GNOME session; this isn't a special decision requiring extra configuration.** Confirmed directly with the user: current NixOS GDM + GNOME already defaults to a Wayland session without any extra option needed — `services.xserver.enable = true` remains required only as the underlying toggle that XWayland and the display/desktop manager modules currently build on, not as a signal that the login session itself will be Xorg-based.

## Risks / Trade-offs

- **Cannot verify the exact module option paths or that GNOME actually boots successfully, since Nix isn't installed and no live NixOS host exists** → Mitigation: same as every prior change in this repo — careful manual construction and review now, `nix flake check` and an actual boot test deferred until Nix/a real host are available. This remains the real acceptance gate, not any individual task checkbox.
- **Every future NixOS host from this flake gets a full desktop stack, including any headless/server host** → Mitigation: this was an explicit, confirmed user choice (not a default I assumed) — if a headless host is ever needed, that's a follow-up change to reintroduce host-level opt-out, not a gap in this change.
- **Firewall now allows mDNS/printer-discovery traffic (`openFirewall = true` on Avahi) in addition to SSH** → Mitigation: scoped to what Avahi's own module opens (mDNS/printer discovery ports), not a blanket firewall disable; consistent with the existing "explicit, minimal firewall allowance" pattern from `add-developer-environment`.
