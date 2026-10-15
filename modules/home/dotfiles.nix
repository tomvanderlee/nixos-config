{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.home.dotfiles;
  dotfilesDir = "${config.home.homeDirectory}/dotfiles";

  # Packages in the external dotfiles repo that are only relevant on one
  # platform. Kept minimal and overridable via excludePackages rather than
  # a full per-platform mapping - see design.md for alternatives considered.
  platformDefaultExcludes =
    lib.optionals (!pkgs.stdenv.hostPlatform.isDarwin) [ "iterm2" ]
    ++ lib.optionals (!pkgs.stdenv.hostPlatform.isLinux) [
      "herbstluftwm"
      "xorg"
    ];

  excludePackages = platformDefaultExcludes ++ cfg.excludePackages;

  # After a fresh clone, keep the clone source as `github` and make `origin`
  # (the push target) the branch upstream. Only config is written, no fetch,
  # since origin may be unreachable at this point.
  postCloneRemotes = lib.optionalString (cfg.originUrl != "") ''
    if [ -d "$DOTFILES_DIR/.git" ]; then
      branch="$(${pkgs.git}/bin/git -C "$DOTFILES_DIR" symbolic-ref --short HEAD)"
      $DRY_RUN_CMD ${pkgs.git}/bin/git -C "$DOTFILES_DIR" remote add origin ${lib.escapeShellArg cfg.originUrl}
      $DRY_RUN_CMD ${pkgs.git}/bin/git -C "$DOTFILES_DIR" config "branch.$branch.remote" origin
      $DRY_RUN_CMD ${pkgs.git}/bin/git -C "$DOTFILES_DIR" config "branch.$branch.merge" "refs/heads/$branch"
    fi
  '';
in
{
  options.home.dotfiles.repoUrl = lib.mkOption {
    type = lib.types.str;
    default = "";
    description = "Git URL of the personal dotfiles repo to clone and stow into $HOME. Leave empty to disable.";
  };

  options.home.dotfiles.originUrl = lib.mkOption {
    type = lib.types.str;
    default = "";
    description = "Optional push-target URL. When set, the initial clone names repoUrl's remote `github` and adds this URL as `origin`, which the checked-out branch then tracks. Existing checkouts are left untouched.";
  };

  options.home.dotfiles.excludePackages = lib.mkOption {
    type = lib.types.listOf lib.types.str;
    default = [ ];
    description = "Names of dotfiles stow packages to always skip, in addition to built-in platform defaults.";
  };

  config = lib.mkIf (cfg.repoUrl != "") {
    home.packages = [
      pkgs.git
      pkgs.stow
    ];

    home.activation.dotfiles = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      DOTFILES_DIR=${lib.escapeShellArg dotfilesDir}
      EXCLUDE_PACKAGES=(${lib.escapeShellArgs excludePackages})
      if [ ! -d "$DOTFILES_DIR/.git" ]; then
        $DRY_RUN_CMD ${pkgs.git}/bin/git clone --recurse-submodules \
          ${
            lib.optionalString (cfg.originUrl != "") "--origin github "
          }${lib.escapeShellArg cfg.repoUrl} "$DOTFILES_DIR"
        ${postCloneRemotes}
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
