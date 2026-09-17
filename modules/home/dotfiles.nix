{ config, lib, pkgs, ... }:
let
  cfg = config.home.dotfiles;
  dotfilesDir = "${config.home.homeDirectory}/dotfiles";
in
{
  options.home.dotfiles.repoUrl = lib.mkOption {
    type = lib.types.str;
    default = "";
    description = "Git URL of the personal dotfiles repo to clone and stow into $HOME. Leave empty to disable.";
  };

  config = lib.mkIf (cfg.repoUrl != "") {
    home.packages = [ pkgs.git pkgs.stow ];

    home.activation.dotfiles = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      DOTFILES_DIR=${lib.escapeShellArg dotfilesDir}
      if [ ! -d "$DOTFILES_DIR/.git" ]; then
        $DRY_RUN_CMD ${pkgs.git}/bin/git clone --recurse-submodules \
          ${lib.escapeShellArg cfg.repoUrl} "$DOTFILES_DIR"
      fi
      if [ -d "$DOTFILES_DIR" ]; then
        for pkg in "$DOTFILES_DIR"/*/; do
          pkg_name="$(basename "$pkg")"
          case "$pkg_name" in .*) continue ;; esac
          $DRY_RUN_CMD ${pkgs.stow}/bin/stow -d "$DOTFILES_DIR" -t ${lib.escapeShellArg config.home.homeDirectory} "$pkg_name" \
            || echo "Warning: stow failed for package '$pkg_name' — skipped." >&2
        done
      fi
    '';
  };
}
