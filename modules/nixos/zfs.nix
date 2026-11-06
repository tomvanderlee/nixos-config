{
  config,
  lib,
  ...
}:
let
  cfg = config.storage.zfs;
in
{
  options.storage.zfs = {
    enable = lib.mkEnableOption "ZFS support (hostId, scrub, trim) for a ZFS-on-root host";

    hostId = lib.mkOption {
      type = lib.types.strMatching "[0-9a-f]{8}";
      example = "8425e349";
      description = ''
        Required by ZFS: 8 lowercase hex characters, unique per machine.
        Generate with `head -c4 /dev/urandom | od -A none -t x4 | tr -d ' '`.
      '';
    };

    encryptedHome.dataset = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      example = "rpool/home";
      description = ''
        Natively encrypted ZFS dataset holding /home (created with
        `-o encryption=aes-256-gcm -o keyformat=passphrase -o keylocation=prompt
        -o mountpoint=legacy`). When set, its passphrase is requested during
        boot, before /home is mounted, so home-manager activation never runs
        against a locked, empty /home. The `fileSystems."/home"` entry itself
        comes from hardware-configuration.nix.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    networking.hostId = cfg.hostId;
    boot.supportedFilesystems = [ "zfs" ];
    services.zfs.autoScrub.enable = true;
    services.zfs.trim.enable = true;

    boot.zfs.requestEncryptionCredentials = lib.mkIf (cfg.encryptedHome.dataset != null) [
      cfg.encryptedHome.dataset
    ];
  };
}
