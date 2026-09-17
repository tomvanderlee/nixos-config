{ pkgs, ... }:
{
  home.packages = with pkgs; [
    gh
    tmux
    htop
    yq-go
    tree-sitter
    docker
    docker-compose
    kubectl
    awscli2
  ];
}
