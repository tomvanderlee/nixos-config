{ pkgs, lib, ... }:
let
  candidateFonts = [ pkgs.nerd-fonts.jetbrains-mono ];
in
{
  home.packages = builtins.filter (lib.meta.availableOn pkgs.stdenv.hostPlatform) candidateFonts;

  # Standalone (non-NixOS) Linux activations don't otherwise get fontconfig
  # pointed at fonts installed via home.packages - see design.md. Harmless
  # no-op on Darwin (font discovery there goes through
  # targets.darwin.fonts, unconditional on this option) and idempotent on
  # NixOS (already defaults to true via useUserPackages).
  fonts.fontconfig.enable = true;
}
