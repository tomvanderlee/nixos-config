{ pkgs, lib, ... }:
let
  candidates = with pkgs; [
    dnsutils # dig, nslookup
    bind.host # host
    whois
    nmap
    mtr
    netcat
    curl
    wget
    rsync
    zip
    unzip
    p7zip
    file
    ncdu
    procps # watch
    less
  ];
in
{
  home.packages = builtins.filter (lib.meta.availableOn pkgs.stdenv.hostPlatform) candidates;
}
