#!/usr/bin/env bash
# Tateru Pro — one-line installer for Linux + macOS.
#
# Usage:
#   curl -fsSL https://tateru.app/install | bash
#   curl -fsSL https://raw.githubusercontent.com/ushanboe/tateru-pro-releases/main/install.sh | bash
#
# Review-first (recommended for security-conscious users):
#   curl -fsSL https://tateru.app/install -o install.sh
#   less install.sh                  # inspect before running
#   bash install.sh
#
# Flags:
#   --deb        Linux only — install the .deb instead of the AppImage
#                (requires sudo; integrates with apt-managed updates)
#   --no-launch  Don't auto-launch the app after install
#   --version=X  Install a specific version (default: latest)
#
# What this script does:
#   1. Detects OS (Linux or macOS)
#   2. Queries the GitHub Releases API for the latest tag
#   3. Downloads the matching artifact to a per-user location
#   4. Linux: chmod +x AppImage in ~/Applications, OR sudo dpkg -i .deb
#   5. macOS: unzip to /Applications, xattr -dr to bypass Gatekeeper
#   6. Optionally launches the app
#
# What this script does NOT do:
#   - No root access on Linux unless you pass --deb
#   - Doesn't touch your home dir beyond ~/Applications (Linux) or /Applications (Mac)
#   - Doesn't add itself to PATH or modify your shell profile
#   - Doesn't capture any telemetry (this script — Tateru itself is BYOK; see Privacy)
#
# Tateru is currently UNSIGNED on both Linux and macOS. The Mac branch
# applies `xattr -dr com.apple.quarantine` automatically because that's
# the documented bypass per MACOS_INSTALL.md. Code signing is on the
# post-beta roadmap (Apple Dev cert active, Azure Trusted Signing for
# Windows planned).

set -euo pipefail

REPO="ushanboe/tateru-pro-releases"
INSTALL_DEB=0
NO_LAUNCH=0
PINNED_VERSION=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --deb)        INSTALL_DEB=1; shift ;;
    --no-launch)  NO_LAUNCH=1; shift ;;
    --version=*)  PINNED_VERSION="${1#--version=}"; shift ;;
    -h|--help)
      cat <<'EOF'
Tateru Pro one-line installer (Linux + macOS).

Usage:
  curl -fsSL https://tateru.app/install | bash
  curl -fsSL https://tateru.app/install | bash -s -- [flags]

Flags:
  --deb              Linux only — install the .deb (requires sudo, apt-managed updates)
  --no-launch        Don't auto-launch the app after install
  --version=X.Y.Z    Install a specific version (default: latest)
  -h, --help         This help text

Full source + review:
  https://raw.githubusercontent.com/ushanboe/tateru-pro-releases/main/install.sh
EOF
      exit 0
      ;;
    *) echo "Unknown arg: $1 (see --help)" >&2; exit 1 ;;
  esac
done

# ── helpers ───────────────────────────────────────────────────────────
fail() { echo "❌ $*" >&2; exit 1; }
info() { echo "ℹ  $*"; }
ok()   { echo "✓ $*"; }

# urlencode: minimal — only spaces, which is all Tateru artifact names have.
urlencode() { echo "${1// /%20}"; }

OS="$(uname -s)"
case "$OS" in
  Linux)  PLATFORM=linux ;;
  Darwin) PLATFORM=macos ;;
  *)      fail "Unsupported OS: $OS (this installer supports Linux + macOS only; Windows users: use the PowerShell one-liner: irm https://tateru.app/install.ps1 | iex)" ;;
esac

# ── resolve version ──────────────────────────────────────────────────
if [[ -n "$PINNED_VERSION" ]]; then
  VERSION="${PINNED_VERSION#v}"
  info "Installing pinned version: $VERSION"
else
  info "Fetching latest release info from GitHub..."
  command -v curl >/dev/null 2>&1 || fail "curl is required but not installed."
  # GitHub API: unauth rate limit 60/hr — fine for installer use.
  LATEST_JSON="$(curl -fsSL "https://api.github.com/repos/${REPO}/releases/latest")" \
    || fail "Couldn't reach GitHub Releases API. Network down? Try: curl -v https://api.github.com"
  # Parse tag_name without jq dependency.
  VERSION="$(echo "$LATEST_JSON" | sed -n 's/.*"tag_name"[[:space:]]*:[[:space:]]*"v\{0,1\}\([^"]*\)".*/\1/p' | head -1)"
  [[ -z "$VERSION" ]] && fail "Couldn't parse latest version from GitHub response."
  ok "Latest version: $VERSION"
fi

# ── per-platform install ──────────────────────────────────────────────
case "$PLATFORM" in
  linux)
    if [[ "$INSTALL_DEB" == "1" ]]; then
      # ── .deb path (apt-managed) ───────────────────────────────────
      command -v dpkg >/dev/null 2>&1 || fail ".deb install requires dpkg (Debian/Ubuntu). Re-run without --deb to use the AppImage instead."
      ASSET="tateru-pro-plus_${VERSION}_amd64.deb"
      URL="https://github.com/${REPO}/releases/download/v${VERSION}/$(urlencode "$ASSET")"
      TMP_DEB="$(mktemp -t tateru-XXXXXX).deb"
      info "Downloading $ASSET (~126 MB)..."
      curl -fL --progress-bar "$URL" -o "$TMP_DEB"
      ok "Downloaded to $TMP_DEB"
      info "Installing via sudo dpkg (you'll be prompted for your password)..."
      sudo dpkg -i "$TMP_DEB" || {
        info "dpkg returned non-zero — trying 'sudo apt --fix-broken install' to resolve missing deps..."
        sudo apt --fix-broken install -y
      }
      rm -f "$TMP_DEB"
      ok "Installed to /opt/Tateru Pro/ — find in Apps menu, or launch with: tateru-pro-plus"
    else
      # ── AppImage path (portable, no sudo) ─────────────────────────
      DEST_DIR="$HOME/Applications"
      mkdir -p "$DEST_DIR"
      ASSET="Tateru Pro-${VERSION}.AppImage"
      URL="https://github.com/${REPO}/releases/download/v${VERSION}/$(urlencode "$ASSET")"
      DEST_PATH="$DEST_DIR/$ASSET"
      info "Downloading $ASSET (~208 MB) to $DEST_DIR..."
      curl -fL --progress-bar "$URL" -o "$DEST_PATH"
      chmod +x "$DEST_PATH"
      ok "Installed: $DEST_PATH"
      info "Note: Apps-menu entry + hicolor icons install on first launch."
    fi
    if [[ "$NO_LAUNCH" == "0" ]]; then
      if [[ "$INSTALL_DEB" == "1" ]]; then
        info "Launching tateru-pro-plus..."
        (tateru-pro-plus >/dev/null 2>&1 &) || info "(launch failed — start from your Apps menu instead)"
      else
        info "Launching..."
        ("$DEST_PATH" >/dev/null 2>&1 &) || info "(launch failed — run manually: \"$DEST_PATH\")"
      fi
    fi
    ;;

  macos)
    # ── Mac .zip + Gatekeeper bypass ──────────────────────────────────
    ASSET="Tateru Pro-${VERSION}-mac.zip"
    URL="https://github.com/${REPO}/releases/download/v${VERSION}/$(urlencode "$ASSET")"
    TMP_ZIP="$(mktemp -t tateru-XXXXXX).zip"
    info "Downloading $ASSET (~199 MB)..."
    curl -fL --progress-bar "$URL" -o "$TMP_ZIP"
    ok "Downloaded to $TMP_ZIP"
    APP_PATH="/Applications/Tateru Pro.app"
    if [[ -d "$APP_PATH" ]]; then
      info "Existing install found at $APP_PATH — replacing..."
      rm -rf "$APP_PATH"
    fi
    info "Unzipping to /Applications..."
    unzip -q -o "$TMP_ZIP" -d /Applications/
    rm -f "$TMP_ZIP"
    info "Applying Gatekeeper bypass (xattr -dr com.apple.quarantine)..."
    info "  Tateru is unsigned during beta. This is the documented bypass —"
    info "  see MACOS_INSTALL.md for details. Code signing planned post-beta."
    xattr -dr com.apple.quarantine "$APP_PATH" 2>/dev/null || \
      info "  xattr returned non-zero — first launch will prompt; right-click → Open to bypass."
    ok "Installed: $APP_PATH"
    if [[ "$NO_LAUNCH" == "0" ]]; then
      info "Launching..."
      open -a "Tateru Pro" || info "(launch failed — open manually from /Applications)"
    fi
    ;;
esac

echo ""
echo "─────────────────────────────────────────────────────────────"
echo "  Tateru Pro v${VERSION} installed."
echo ""
echo "  First launch sets up your data dir at ~/.config/tateru-pro-plus"
echo "  (Linux) or ~/Library/Application Support/tateru-pro-plus (Mac)."
echo ""
echo "  Quick Start:  https://tateru.app/quick-start"
echo "  Privacy:      https://tateru.app/privacy"
echo "  Uninstall:    bash <(curl -fsSL https://raw.githubusercontent.com/${REPO}/main/uninstall-${PLATFORM}.sh)"
echo "─────────────────────────────────────────────────────────────"
