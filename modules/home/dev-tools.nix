{ pkgs, ... }:
{
  home.packages = with pkgs; [
    gh
    tmux
    htop
    yq-go
    docker
    docker-compose
    kubectl
    awscli2
  ];
}
