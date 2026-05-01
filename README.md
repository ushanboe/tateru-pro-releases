# Tateru Pro — Public Release Binaries

This repository hosts the **public release binaries** for Tateru Pro, an AI-driven Android app pipeline (with experimental macOS + iOS app builds). The product source code lives in a separate private repository.

- **Product website:** https://tateru.app
- **Latest release:** https://github.com/ushanboe/tateru-pro-releases/releases/latest
- **Quick Start guide:** https://tateru.app/quick-start
- **Beta access:** https://tateru.app/beta
- **Support:** support@tateru.app

---

## What's in each release

| Platform | File | Approx size |
|---|---|---|
| Linux x64 | `Tateru.Pro-<version>.AppImage` | ~213 MB |
| Linux x64 | `tateru-pro-plus_<version>_amd64.deb` | ~131 MB |
| macOS (Intel + Apple Silicon via Rosetta 2) | `Tateru.Pro-<version>-mac.zip` | ~204 MB |
| Windows x64 | `Tateru.Pro-<version>-win.zip` | ~230 MB |

> **Note on filenames:** GitHub stores release assets with **dots** in place of spaces. So the file you download is `Tateru.Pro-1.0.0-beta.9.11-mac.zip` (with dots). Once unzipped, the `.app` bundle inside is named `Tateru Pro.app` (with a space) — that's normal.

Every release ships a `SHA256SUMS-<short-version>` file. Verify with `sha256sum -c SHA256SUMS-<short-version> --ignore-missing`.

---

## Where your data lives

Tateru stores all user data — login, license, generated projects, built APKs, SQLite DB — **outside** the app bundle, so reinstalls and updates never touch your work.

| OS | Data dir |
|---|---|
| Linux | `~/.config/tateru-pro-plus/data/` |
| macOS | `~/Library/Application Support/tateru-pro-plus/data/` |
| Windows | `%APPDATA%\tateru-pro-plus\data\` |

LLM API keys are stored separately in your OS keychain (macOS Keychain / GNOME Keyring / Windows Credential Manager).

The Uninstall sections below are split into **app-only** (preserves your data) and **factory reset** (wipes data + keys).

---

## Install — Linux x64

### Option A — AppImage (no install, single-file portable)

```bash
cd ~/Downloads
VERSION=1.0.0-beta.9.11   # ← latest as of 2026-05-01; check the Releases page for newer
curl -LO "https://github.com/ushanboe/tateru-pro-releases/releases/download/v${VERSION}/Tateru.Pro-${VERSION}.AppImage"

# Optional: verify checksum
curl -LO "https://github.com/ushanboe/tateru-pro-releases/releases/download/v${VERSION}/SHA256SUMS-beta.9.11"
sha256sum -c SHA256SUMS-beta.9.11 --ignore-missing

# Install libfuse2 if Ubuntu 22.04+ (no longer ships by default)
sudo apt install libfuse2t64    # Ubuntu 24.04+
# OR: sudo apt install libfuse2  # Ubuntu 22.04 and earlier

# Make executable + run
chmod +x "Tateru.Pro-${VERSION}.AppImage"
"./Tateru.Pro-${VERSION}.AppImage"
```

**No `sudo` available?** Use the no-root extract-and-run mode (slower first launch, no libfuse2 needed):
```bash
"./Tateru.Pro-${VERSION}.AppImage" --appimage-extract-and-run
```

### Option B — Debian package (system install with menu integration)

```bash
VERSION=1.0.0-beta.9.11   # ← update to current
curl -LO "https://github.com/ushanboe/tateru-pro-releases/releases/download/v${VERSION}/tateru-pro-plus_${VERSION}_amd64.deb"
sudo apt install "./tateru-pro-plus_${VERSION}_amd64.deb"

# Then launch from your application menu, or:
tateru-pro-plus
```

### Option C — Browser download

Open the [latest release](https://github.com/ushanboe/tateru-pro-releases/releases/latest), click the `.AppImage` or `.deb` asset, then follow the steps above.

### Uninstall — Linux

**App-only** (preserves your projects, login, and license):

| Install method | Remove command |
|---|---|
| AppImage | `rm "Tateru.Pro-1.0.0-beta.9.11.AppImage"` (just delete the file you downloaded) |
| Debian package | `sudo apt remove tateru-pro-plus` |

**Factory reset** (also wipes data dir, projects, login, cached models — irreversible):

```bash
# Quit the app first
pkill -f "Tateru Pro" 2>/dev/null

# Wipe data dir (DB, projects, built APKs, license cache)
rm -rf "$HOME/.config/tateru-pro-plus"

# Wipe keyring entries (LLM API keys)
# GNOME: open Seahorse / Passwords and Keys → search "tateru" → delete
# KDE:   open KWallet Manager → search "tateru" → delete
```

---

## Install — macOS (Intel + Apple Silicon)

> **Unsigned during beta** — macOS Gatekeeper will warn on first launch. Right-click → Open bypasses cleanly. See [MACOS_INSTALL.md](MACOS_INSTALL.md) for the full guide.

### Quick install (Terminal)

```bash
osascript -e 'quit app "Tateru Pro"' 2>/dev/null   # quit any running version

VERSION=1.0.0-beta.9.11   # ← update to current
cd ~/Downloads
curl -LO "https://github.com/ushanboe/tateru-pro-releases/releases/download/v${VERSION}/Tateru.Pro-${VERSION}-mac.zip"
unzip -q "Tateru.Pro-${VERSION}-mac.zip"
mv "Tateru Pro.app" /Applications/
xattr -dr com.apple.quarantine "/Applications/Tateru Pro.app"   # strip Gatekeeper quarantine
open "/Applications/Tateru Pro.app"
```

### Quick install (GUI)

1. Open the [latest release](https://github.com/ushanboe/tateru-pro-releases/releases/latest) in Safari.
2. Click `Tateru.Pro-<version>-mac.zip` to download.
3. Double-click the downloaded zip in Finder → produces `Tateru Pro.app`.
4. Drag `Tateru Pro.app` into **Applications**.
5. **Right-click** the app → **Open** → click **Open** in the warning (one-time only — subsequent launches work via double-click).

### Uninstall — macOS

**App-only** (preserves your projects, login, and license):

```bash
# Quit the app
osascript -e 'quit app "Tateru Pro"' 2>/dev/null

# Delete the .app bundle
rm -rf "/Applications/Tateru Pro.app"
```

Or via Finder: drag `Tateru Pro` from Applications → Trash.

**Factory reset** (also wipes data dir, projects, login, cached models — irreversible):

```bash
osascript -e 'quit app "Tateru Pro"' 2>/dev/null
rm -rf "/Applications/Tateru Pro.app"
rm -rf "$HOME/Library/Application Support/tateru-pro-plus"
rm -rf "$HOME/Library/Caches/com.tateru.pro.plus"
rm -rf "$HOME/Library/Preferences/com.tateru.pro.plus.plist"
rm -rf "$HOME/Library/Logs/tateru-pro-plus"
rm -rf "$HOME/.tateru-pro"          # cloud-client cache (JWT, offline queue)
```

To also remove your stored LLM API keys: open **Keychain Access.app** → search `tateru` → delete the matching entries.

For the deeper Mac guide (fast-reset cycle for testing, troubleshooting, Console crash report path), see [MACOS_INSTALL.md](MACOS_INSTALL.md).

---

## Install — Windows x64

> **Unsigned during beta** — SmartScreen will warn on first launch. "More info → Run anyway" is the bypass.

### Quick install (PowerShell)

```powershell
$VERSION = "1.0.0-beta.9.11"   # ← update to current

# Download (no auth needed)
Invoke-WebRequest `
  -Uri "https://github.com/ushanboe/tateru-pro-releases/releases/download/v$VERSION/Tateru.Pro-$VERSION-win.zip" `
  -OutFile "$env:USERPROFILE\Downloads\Tateru-Pro-$VERSION-win.zip"

# Extract to %LOCALAPPDATA%\Programs\Tateru Pro (or any folder you choose)
Expand-Archive `
  -Path "$env:USERPROFILE\Downloads\Tateru-Pro-$VERSION-win.zip" `
  -DestinationPath "$env:LOCALAPPDATA\Programs\Tateru Pro"

# Run
& "$env:LOCALAPPDATA\Programs\Tateru Pro\win-unpacked\Tateru Pro.exe"
```

### Quick install (GUI)

1. Open the [latest release](https://github.com/ushanboe/tateru-pro-releases/releases/latest) in Edge or Chrome.
2. Click `Tateru.Pro-<version>-win.zip` to download (~230 MB).
3. Right-click the downloaded zip → **Extract All** → choose a destination folder (e.g. `C:\Tateru Pro\`).
4. Open the extracted folder → enter the `win-unpacked` subfolder → double-click `Tateru Pro.exe`.

(Optional) Right-click `Tateru Pro.exe` → **Send to** → **Desktop (create shortcut)** for a launcher icon.

### First launch — SmartScreen bypass

Windows Defender SmartScreen blocks unsigned binaries by default:

1. Double-click `Tateru Pro.exe` → blue *"Windows protected your PC"* dialog appears.
2. Click **More info** (small text under the message).
3. Click the **Run anyway** button that appears.
4. App launches; subsequent launches skip the warning.

If SmartScreen is set to **Block** (some corporate policies), the **Run anyway** button won't appear. Workaround: right-click the `.exe` → **Properties** → tick **Unblock** at the bottom → **OK** → re-run.

### Uninstall — Windows

**App-only** (preserves your projects, login, and license):

Delete the folder where you extracted the zip.

```powershell
# If you extracted to %LOCALAPPDATA%\Programs\Tateru Pro per the install above:
Remove-Item -Recurse -Force "$env:LOCALAPPDATA\Programs\Tateru Pro"
```

Or via File Explorer: navigate to the extracted folder → right-click → Delete.

**Factory reset** (also wipes data dir, projects, login, cached models — irreversible):

```powershell
# Stop the app if it's running
Stop-Process -Name "Tateru Pro" -Force -ErrorAction SilentlyContinue

# Delete the extracted bundle
Remove-Item -Recurse -Force "$env:LOCALAPPDATA\Programs\Tateru Pro"

# Wipe data dir (DB, projects, built APKs, license cache)
Remove-Item -Recurse -Force "$env:APPDATA\tateru-pro-plus"

# Wipe cloud-client cache (JWT, offline queue)
Remove-Item -Recurse -Force "$env:USERPROFILE\.tateru-pro"
```

To also remove your stored LLM API keys: open **Credential Manager** (Start → search "Credential Manager") → **Windows Credentials** → find entries beginning with `Tateru Pro` → **Remove**.

### Known Windows-specific notes

- **No `.exe` installer / NSIS** — cross-compiling from Linux requires Wine on the build host. Currently shipping as `.zip` until 1.0.
- **No auto-updater on Windows yet** — manual download of new releases required.

---

## Beta status

Currently in **closed beta**. Use an invite code from the [beta access page](https://tateru.app/beta) to register.

Tateru Pro is under active development. Patch releases ship on a roughly daily cadence as bugs surface from beta testers — see the [Releases](https://github.com/ushanboe/tateru-pro-releases/releases) page for the full history.

### Build target support

| Target | Status |
|---|---|
| Android APK | ✅ Production-ready |
| macOS `.app` | 🧪 Experimental (Mac host required) |
| iOS `.app` | 🧪 Experimental, compile-only (signing + iPhone install coming) |

See [tateru.app/quick-start](https://tateru.app/quick-start) for the full walkthrough.

---

## License + privacy

The Tateru Pro app is proprietary software. By downloading and installing, you agree to the [Terms of Use](https://tateru.app/terms) and [Privacy Policy](https://tateru.app/privacy).
