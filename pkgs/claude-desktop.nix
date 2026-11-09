# Repackages Anthropic's official Claude Desktop .deb (beta, Linux only).
# See https://code.claude.com/docs/en/desktop-linux. To bump, update `version`
# and both hashes from the apt index:
#   https://downloads.claude.ai/claude-desktop/apt/stable/dists/stable/main/binary-<arch>/Packages
{
  lib,
  stdenv,
  fetchurl,
  dpkg,
  autoPatchelfHook,
  makeWrapper,
  alsa-lib,
  at-spi2-core,
  cairo,
  cups,
  dbus,
  expat,
  glib,
  gtk3,
  libappindicator-gtk3,
  libdrm,
  libGL,
  libnotify,
  libcap_ng,
  libsecret,
  libseccomp,
  libuuid,
  libxkbcommon,
  libgbm,
  nspr,
  nss,
  pango,
  pipewire,
  systemd,
  vulkan-loader,
  libx11,
  libxcb,
  libxcomposite,
  libxdamage,
  libxext,
  libxfixes,
  libxrandr,
  libxtst,
  xdg-utils,
}:
let
  version = "4.23118.0";
  sources = {
    x86_64-linux = {
      arch = "amd64";
      hash = "sha256-GtmW6MqrBcmzdGRgUcQMtrudhPNxdW8VuNNyiJdRWpc=";
    };
    aarch64-linux = {
      arch = "arm64";
      hash = "sha256-tMBOCDOLMh9cAlQ6tr6BnLufOO8FGj59j/3FtNUkjqQ=";
    };
  };
  src' =
    sources.${stdenv.hostPlatform.system}
      or (throw "claude-desktop: unsupported system ${stdenv.hostPlatform.system}");
in
stdenv.mkDerivation {
  pname = "claude-desktop";
  inherit version;

  src = fetchurl {
    url = "https://downloads.claude.ai/claude-desktop/apt/stable/pool/main/c/claude-desktop/claude-desktop_${version}_${src'.arch}.deb";
    inherit (src') hash;
  };

  nativeBuildInputs = [
    dpkg
    autoPatchelfHook
    makeWrapper
  ];

  buildInputs = [
    alsa-lib
    at-spi2-core
    cairo
    cups
    dbus
    expat
    glib
    gtk3
    libdrm
    libgbm
    libcap_ng
    libnotify
    libsecret
    libseccomp
    libuuid
    libxkbcommon
    nspr
    nss
    pango
    pipewire
    libx11
    libxcb
    libxcomposite
    libxdamage
    libxext
    libxfixes
    libxrandr
    libxtst
    stdenv.cc.cc.lib
  ];

  # Libraries Chromium/Electron dlopen()s at runtime.
  runtimeDependencies = [
    (lib.getLib systemd)
    libappindicator-gtk3
    libGL
    libnotify
    libsecret
    pipewire
    vulkan-loader
  ];

  unpackPhase = "dpkg --fsys-tarfile $src | tar -x --no-same-permissions --no-same-owner";

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib $out/bin $out/share
    cp -r usr/lib/claude-desktop $out/lib/claude-desktop
    cp -r usr/share/icons $out/share/icons
    mkdir -p $out/share/applications
    cp usr/share/applications/com.anthropic.Claude.desktop $out/share/applications/
    substituteInPlace $out/share/applications/com.anthropic.Claude.desktop \
      --replace-fail "Exec=claude-desktop" "Exec=$out/bin/claude-desktop"

    # Native Wayland on GNOME; "auto" falls back to X11 elsewhere.
    makeWrapper $out/lib/claude-desktop/claude-desktop $out/bin/claude-desktop \
      --prefix PATH : ${lib.makeBinPath [ xdg-utils ]} \
      --add-flags "--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations"

    runHook postInstall
  '';

  meta = {
    description = "Claude Desktop app for Linux (official Anthropic build, beta)";
    homepage = "https://claude.ai";
    license = lib.licenses.unfree;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
    mainProgram = "claude-desktop";
  };
}
