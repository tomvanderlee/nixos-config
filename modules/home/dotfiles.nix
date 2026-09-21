{ config, lib, pkgs, ... }:
let
  cfg = config.home.dotfiles;
  dotfilesDir = "${config.home.homeDirectory}/dotfiles";

  # Packages in the external dotfiles repo that are only relevant on one
  # platform. Kept minimal and overridable via excludePackages rather than
  # a full per-platform mapping - see design.md for alternatives considered.
  platformDefaultExcludes =
    lib.optionals (!pkgs.stdenv.hostPlatform.isDarwin) [ "iterm2" ]
    ++ lib.optionals (!pkgs.stdenv.hostPlatform.isLinux) [ "herbstluftwm" "xorg" ];

  excludePackages = platformDefaultExcludes ++ cfg.excludePackages;
in
{
  options.home.dotfiles.repoUrl = lib.mkOption {
    type = lib.types.str;
    default = "";
    description = "Git URL of the personal dotfiles repo to clone and stow into $HOME. Leave empty to disable.";
  };

  options.home.dotfiles.excludePackages = lib.mkOption {
    type = lib.types.listOf lib.types.str;
    default = [ ];
    description = "Names of dotfiles stow packages to always skip, in addition to built-in platform defaults.";
  };

  config = lib.mkIf (cfg.repoUrl != "") {
    home.packages = [ pkgs.git pkgs.stow ];

    home.activation.dotfiles = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      DOTFILES_DIR=${lib.escapeShellArg dotfilesDir}
      EXCLUDE_PACKAGES=(${lib.escapeShellArgs excludePackages})
      if [ ! -d "$DOTFILES_DIR/.git" ]; then
        $DRY_RUN_CMD ${pkgs.git}/bin/git clone --recurse-submodules \
          ${lib.escapeShellArg cfg.repoUrl} "$DOTFILES_DIR"
      fi
      if [ -d "$DOTFILES_DIR" ]; then
        for pkg in "$DOTFILES_DIR"/*/; do
          pkg_name="$(basename "$pkg")"
          case "$pkg_name" in .*) continue ;; esac
          skip=false
          for excluded in "''${EXCLUDE_PACKAGES[@]}"; do
            if [ "$pkg_name" = "$excluded" ]; then
              skip=true
              break
            fi
          done
          if [ "$skip" = true ]; then
            echo "Skipping dotfiles package '$pkg_name' — not relevant on this platform." >&2
            continue
          fi
          $DRY_RUN_CMD ${pkgs.stow}/bin/stow -d "$DOTFILES_DIR" -t ${lib.escapeShellArg config.home.homeDirectory} "$pkg_name" \
            || echo "Warning: stow failed for package '$pkg_name' — skipped." >&2
        done
      fi
    '';
  };
}
