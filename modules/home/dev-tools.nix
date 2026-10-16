{ pkgs, lib, ... }:
{
  programs.nh.enable = true;

  home.packages =
    (with pkgs; [
      gh
      tmux
      htop
      yq-go
      docker
      docker-compose
      kubectl
      kubernetes-helm
      awscli2
      bitwarden-cli
      uv
      openssl
    ])
    ++ lib.optional (lib.meta.availableOn pkgs.stdenv.hostPlatform pkgs.claude-code) pkgs.claude-code;
}
