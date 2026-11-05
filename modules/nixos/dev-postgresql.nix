{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.development.postgresql.enable = lib.mkEnableOption "a loopback-only PostgreSQL server for local development";

  config = lib.mkIf config.development.postgresql.enable {
    services.postgresql = {
      enable = true;
      # Pinned so a nixpkgs bump can't cause a major-version data-dir mismatch.
      package = pkgs.postgresql_18;
      enableTCPIP = true;
      settings = {
        listen_addresses = lib.mkForce "127.0.0.1,::1";
        port = 5432;
      };
      # No ensureDatabases/ensureUsers: create databases on demand, e.g.
      # `createdb -h localhost -U postgres <name>`.
      # Replaces the default pg_hba: socket peer auth (so `sudo -u postgres
      # psql` works) plus passwordless access over loopback TCP only.
      authentication = lib.mkForce ''
        local all all peer
        host all all 127.0.0.1/32 trust
        host all all ::1/128 trust
      '';
    };

    # Provides `psql`, `createdb`, etc. on PATH.
    environment.systemPackages = [ config.services.postgresql.package ];
  };
}
