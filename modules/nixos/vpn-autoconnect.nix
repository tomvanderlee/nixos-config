{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.vpn.autoConnect;

  script = pkgs.writeShellScript "vpn-autoconnect" ''
    # NetworkManager dispatcher: $1 = interface, $2 = action.
    export PATH=${
      lib.makeBinPath [
        pkgs.networkmanager
        pkgs.coreutils
        pkgs.gnugrep
        pkgs.util-linux
      ]
    }

    profile=${lib.escapeShellArg cfg.connectionName}
    trusted_ssids=(${lib.escapeShellArgs cfg.trustedSsids})

    log() { logger -t vpn-autoconnect -- "$*"; }

    case "''${2:-}" in
      up | down) ;;
      *) exit 0 ;;
    esac

    # Only react to physical devices; ignores wg0 (so we never trigger
    # ourselves), loopback, container bridges and veths.
    case "$(nmcli --escape no -g GENERAL.TYPE device show "$1" 2>/dev/null)" in
      wifi | ethernet) ;;
      *) exit 0 ;;
    esac

    profile_uuid=$(nmcli --escape no -g connection.uuid connection show id "$profile" 2>/dev/null | head -n1)
    if [ -z "$profile_uuid" ]; then
      log "profile '$profile' not found; doing nothing"
      exit 0
    fi

    wired=0
    wifi_seen=0
    wifi_trusted=0
    vpn_active=0
    while IFS=: read -r type uuid; do
      case "$type" in
        802-3-ethernet) wired=1 ;;
        802-11-wireless)
          wifi_seen=1
          ssid=$(nmcli --escape no -g 802-11-wireless.ssid connection show uuid "$uuid" 2>/dev/null)
          for t in "''${trusted_ssids[@]}"; do
            [ "$ssid" = "$t" ] && wifi_trusted=1
          done
          ;;
      esac
      [ "$uuid" = "$profile_uuid" ] && vpn_active=1
    done < <(nmcli --escape no -t -f TYPE,UUID connection show --active)

    if [ "$wired" = 1 ] || [ "$wifi_trusted" = 1 ]; then
      if [ "$vpn_active" = 1 ]; then
        log "trusted network; bringing '$profile' down"
        nmcli --wait 0 connection down uuid "$profile_uuid" || log "failed to bring '$profile' down"
      fi
    elif [ "$wifi_seen" = 1 ]; then
      if [ "$vpn_active" = 0 ]; then
        log "untrusted network; bringing '$profile' up"
        nmcli --wait 0 connection up uuid "$profile_uuid" || log "failed to bring '$profile' up"
      fi
    fi
    # No physical connection active: leave the VPN as it is.
    exit 0
  '';
in
{
  options.vpn.autoConnect = {
    enable = lib.mkEnableOption "automatically connecting a NetworkManager VPN profile on untrusted networks";

    connectionName = lib.mkOption {
      type = lib.types.str;
      default = "Home";
      description = "Name of the existing NetworkManager profile (created in GNOME Settings) to manage.";
    };

    trustedSsids = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Wi-Fi SSIDs on which the VPN is brought down. Any wired connection is always trusted.";
    };
  };

  config = lib.mkIf cfg.enable {
    networking.networkmanager.dispatcherScripts = [
      {
        source = script;
        type = "basic";
      }
    ];
  };
}
