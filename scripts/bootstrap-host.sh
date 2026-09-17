#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: bootstrap-host <hostname> --root <path> --state-version <version> [--system <system>] [--force]

Scaffolds hosts/<hostname>/ from hosts/template, ready to be picked up
automatically as nixosConfigurations.<hostname> — no flake.nix edit needed.
Must be run from the root of the nix-config checkout.

  --root <path>          Required. Where to read hardware-configuration.nix
                          from: <path>/etc/nixos/hardware-configuration.nix.
                          Use /mnt when running from a NixOS live/installer
                          environment against a freshly mounted install
                          target; use / when adopting an already-installed
                          system. There is no default — this is always
                          explicit so the live environment's own /etc/nixos
                          is never read by accident.
  --state-version <ver>  Required, e.g. 24.05. Never change this after the
                          host's first install.
  --system <system>      Optional. Defaults to x86_64-linux.
  --force                Overwrite an existing hosts/<hostname> directory.
EOF
}

hostname=""
root=""
state_version=""
system="x86_64-linux"
force=0

while [ $# -gt 0 ]; do
  case "$1" in
  --root)
    root="$2"
    shift 2
    ;;
  --state-version)
    state_version="$2"
    shift 2
    ;;
  --system)
    system="$2"
    shift 2
    ;;
  --force)
    force=1
    shift
    ;;
  -h | --help)
    usage
    exit 0
    ;;
  -*)
    echo "Error: unknown flag '$1'." >&2
    usage >&2
    exit 1
    ;;
  *)
    if [ -n "$hostname" ]; then
      echo "Error: unexpected extra argument '$1'." >&2
      exit 1
    fi
    hostname="$1"
    shift
    ;;
  esac
done

if [ -z "$hostname" ]; then
  echo "Error: <hostname> is required." >&2
  usage >&2
  exit 1
fi

if [[ ! "$hostname" =~ ^[a-zA-Z0-9][a-zA-Z0-9-]*$ ]]; then
  echo "Error: '$hostname' is not a valid hostname (letters, digits, hyphens; must not start with a hyphen)." >&2
  exit 1
fi

if [ -z "$root" ]; then
  echo "Error: --root is required (e.g. --root /mnt for a fresh install, --root / to adopt the running system)." >&2
  exit 1
fi

if [ -z "$state_version" ]; then
  echo "Error: --state-version is required (e.g. --state-version 24.05)." >&2
  exit 1
fi

repo_root="$(pwd)"
template_dir="$repo_root/hosts/template"
host_dir="$repo_root/hosts/$hostname"

if [ ! -d "$template_dir" ]; then
  echo "Error: hosts/template not found under the current directory ($repo_root)." >&2
  echo "Run this from the root of the nix-config checkout." >&2
  exit 1
fi

if [ -e "$host_dir" ] && [ "$force" -ne 1 ]; then
  echo "Error: $host_dir already exists. Pass --force to overwrite." >&2
  exit 1
fi

rm -rf "$host_dir"
cp -r "$template_dir" "$host_dir"

sed -i.bak \
  -e "s/networking.hostName = \"CHANGEME\";/networking.hostName = \"$hostname\";/" \
  -e "s/system.stateVersion = \"CHANGEME\";/system.stateVersion = \"$state_version\";/" \
  "$host_dir/configuration.nix"
rm -f "$host_dir/configuration.nix.bak"

printf '%s' "$system" >"$host_dir/system"

# Always read from <root>/etc/nixos, never bare /etc/nixos — this is what
# keeps a live-installer run from picking up the live ISO's own hardware
# config instead of the freshly mounted install target's.
hw_config_src="$root/etc/nixos/hardware-configuration.nix"

if [ ! -f "$hw_config_src" ] && command -v nixos-generate-config >/dev/null 2>&1; then
  echo "No hardware-configuration.nix found at $hw_config_src — generating it with 'nixos-generate-config --root $root' ..."
  nixos-generate-config --root "$root"
fi

if [ ! -f "$hw_config_src" ]; then
  echo "Error: could not find or generate hardware-configuration.nix at $hw_config_src." >&2
  echo "Generate it yourself (e.g. 'nixos-generate-config --root $root') and re-run." >&2
  exit 1
fi

cp "$hw_config_src" "$host_dir/hardware-configuration.nix"

cat <<EOF

Host '$hostname' scaffolded at hosts/$hostname

Next steps:
  1. Review hosts/$hostname/configuration.nix (boot loader choice, etc.)
  2. git -C "$repo_root" add "hosts/$hostname"
  3. Install or rebuild using <flake>#<host> syntax:
       Fresh install:    nixos-install --root $root --flake "$repo_root#$hostname"
       Existing system:  sudo nixos-rebuild switch --flake "$repo_root#$hostname"
EOF
