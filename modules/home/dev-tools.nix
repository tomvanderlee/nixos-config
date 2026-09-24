{ pkgs, lib, ... }:
{
  home.packages =
    (with pkgs; [
      gh
      tmux
      htop
      yq-go
      docker
      docker-compose
      kubectl
      awscli2
      bitwarden-cli
      uv
    ])
    ++ lib.optional (lib.meta.availableOn pkgs.stdenv.hostPlatform pkgs.claude-code) pkgs.claude-code;
}
