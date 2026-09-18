## 1. GNOME desktop and login manager

- [x] 1.1 In `modules/nixos/common.nix`, add `services.xserver.enable = true;` — verify by reading the file
- [x] 1.2 Add `services.displayManager.gdm.enable = true;` and `services.desktopManager.gnome.enable = true;` — verify by reading the added block, and flag the option-path uncertainty from design.md (post-migration `services.displayManager.*`/`services.desktopManager.*` vs. older `services.xserver.displayManager.*`/`services.xserver.desktopManager.*`) as a known risk to re-check once `nix flake check` can run

## 2. Networking and audio companions

- [x] 2.1 Add `networking.networkmanager.enable = true;` — verify by reading the added line
- [x] 2.2 Add `services.pipewire = { enable = true; pulse.enable = true; };` and `security.rtkit.enable = true;` — verify by reading the added block

## 3. Printing

- [x] 3.1 Add `services.printing.enable = true;` — verify by reading the added line
- [x] 3.2 Add `services.avahi = { enable = true; nssmdns4 = true; openFirewall = true; };` — verify by reading the added block, and confirm `openFirewall = true` is present so mDNS/printer discovery isn't blocked by the firewall enabled in `add-developer-environment`

## 4. Documentation

- [x] 4.1 Update `README.md` to document that NixOS hosts from this flake now boot into GNOME (GDM login) by default, with NetworkManager, PipeWire, and CUPS+Avahi printing enabled as necessary companions — verify by reading the updated section for consistency with the actual module changes

## 5. Validation

- [x] 5.1 Run `nix flake check` and confirm `modules/nixos/common.nix` still evaluates without error with the new services added, resolving the option-path question from task 1.2 (ran on a machine with Nix installed — passed, confirming the post-migration `services.displayManager.*`/`services.desktopManager.*` option paths are correct)
- [x] 5.2 Manually trace through each spec scenario in `specs/gnome-desktop/spec.md` against the implemented module, confirming each is satisfied by inspection given #5.1 cannot run locally
