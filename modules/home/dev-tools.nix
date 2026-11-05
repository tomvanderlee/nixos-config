{ pkgs, lib, ... }:
{
  programs.nh.enable = true;

  # uv must use its own prebuilt interpreters: the Nix-built python3 on PATH
  # (installed for mason.nvim) has a store RUNPATH and ignores nix-ld, so
  # prebuilt native wheels (e.g. greenlet needing libstdc++) can't load there.
  home.sessionVariables.UV_PYTHON_PREFERENCE = "only-managed";
  # Default to the 3.14 series: the newest managed release (3.15) lacks wheels
  # for some dependencies (e.g. cffi), and development projects should not
  # fall over to source builds. A .python-version or --python still wins.
  home.sessionVariables.UV_PYTHON = "3.14";

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
