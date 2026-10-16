{ pkgs, ... }:
{
  # Toolchains come from nixpkgs (not rustup) so they're reproducible and work
  # the same on NixOS, other Linux, and macOS. The C linker Rust needs is
  # provided by stdenv.cc in editor.nix.
  home.packages = with pkgs; [
    go
    gopls
    cargo
    rustc
    rustfmt
    clippy
    rust-analyzer
  ];
}
