{ pkgs, lib, ... }:
{
  programs.nh.enable = true;

  # uv is configured through its own user config files rather than session
  # variables: nothing on this host sources home-manager's hm-session-vars.sh
  # (bash is owned by the dotfiles repo), so variables never reach the shell.
  #
  # Only managed interpreters: the Nix-built python3 on PATH (installed for
  # mason.nvim) has a store RUNPATH and ignores nix-ld, so prebuilt native
  # wheels (e.g. greenlet needing libstdc++) can't load there.
  xdg.configFile."uv/uv.toml".text = ''
    python-preference = "only-managed"
  '';
  # Default to the 3.14 series: the newest managed release (3.15) lacks wheels
  # for some dependencies (e.g. cffi). A project .python-version or --python
  # still wins.
  xdg.configFile."uv/.python-version".text = "3.14\n";

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
      ssm-session-manager-plugin
      google-cloud-sdk
      google-cloud-sql-proxy
      (azure-cli.withExtensions [ azure-cli.extensions.bastion ])
      bitwarden-cli
      uv
      openssl
      wireguard-tools
    ])
    ++ lib.optional (lib.meta.availableOn pkgs.stdenv.hostPlatform pkgs.claude-code) pkgs.claude-code;
}
