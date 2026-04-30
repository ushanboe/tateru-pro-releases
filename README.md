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

> **Note on filenames:** GitHub stores release assets with **dots** in place of spaces. So the file you download is `Tateru.Pro-1.0.0-beta.9.7-mac.zip` (with dots). Once unzipped, the `.app` bundle inside is named `Tateru Pro.app` (with a space) — that's normal.

Every release ships a `SHA256SUMS-<short-version>` file. Verify with `sha256sum -c SHA256SUMS-<short-version> --ignore-missing`.

---

## Install — Linux x64

### Option A — AppImage (no install, single-file portable)

```bash
# 1. Find the latest version from https://github.com/ushanboe/tateru-pro-releases/releases/latest
# 2. Replace 1.0.0-beta.X.Y below with the current version, then:

cd ~/Downloads
VERSION=1.0.0-beta.9.7   # ← update to current
curl -LO "https://github.com/ushanboe/tateru-pro-releases/releases/download/v${VERSION}/Tateru.Pro-${VERSION}.AppImage"

# Optional: verify checksum
curl -LO "https://github.com/ushanboe/tateru-pro-releases/releases/download/v${VERSION}/SHA256SUMS-beta.9.7"
sha256sum -c SHA256SUMS-beta.9.7 --ignore-missing

# Install libfuse2 if Ubuntu 22.04+ (no longer ships by default)
sudo apt install libfuse2t64    # Ubuntu 24.04+
# OR: sudo apt install libfuse2  # Ubuntu 22.04 and earlier

# Make executable + run
chmod +x "Tateru.Pro-${VERSION}.AppImage"
"./Tateru.Pro-${VERSION}.AppImage"
```

**No `sudo` available?** Use the no-root extract-and-run mode:
```bash
"./Tateru.Pro-${VERSION}.AppImage" --appimage-extract-and-run
```
Slower first launch (extracts to `/tmp`) but no libfuse2 dependency.

### Option B — Debian package (system install with menu integration)

```bash
VERSION=1.0.0-beta.9.7   # ← update to current
curl -LO "https://github.com/ushanboe/tateru-pro-releases/releases/download/v${VERSION}/tateru-pro-plus_${VERSION}_amd64.deb"
sudo apt install "./tateru-pro-plus_${VERSION}_amd64.deb"

# Then launch from your application menu, or:
tateru-pro-plus
```

To uninstall:
```bash
sudo apt remove tateru-pro-plus
```

### Option C — Browser download

Open the [latest release](https://github.com/ushanboe/tateru-pro-releases/releases/latest), click the `.AppImage` or `.deb` asset, then follow steps 4 onwards above.

---

## Install — macOS (Intel + Apple Silicon)

> **Unsigned during beta** — macOS Gatekeeper will warn on first launch. Right-click → Open bypasses cleanly. See [MACOS_INSTALL.md](MACOS_INSTALL.md) for the full guide.

### Quick install (Terminal)

```bash
osascript -e 'quit app "Tateru Pro"' 2>/dev/null   # quit any running version

VERSION=1.0.0-beta.9.7   # ← update to current
cd ~/Downloads
curl -LO "https://github.com/ushanboe/tateru-pro-releases/releases/download/v${VERSION}/Tateru.Pro-${VERSION}-mac.zip"
unzip -q "Tateru.Pro-${VERSION}-mac.zip"
mv "Tateru Pro.app" /Applications/
xattr -dr com.apple.quarantine "/Applications/Tateru Pro.app"   # strip Gatekeeper quarantine
open "/Applications/Tateru Pro.app"
```

### Quick install (GUI)

1. Open the [latest release](https://github.com/ushanboe/tateru-pro-releases/releases/latest) in Safari
2. Click `Tateru.Pro-<version>-mac.zip` to download
3. Double-click the downloaded zip in Finder → produces `Tateru Pro.app`
4. Drag `Tateru Pro.app` into **Applications**
5. **Right-click** the app → **Open** → click **Open** in the warning (one-time only — subsequent launches work via double-click)

### Where data lives

Account, projects, settings, built APKs all persist at `~/Library/Application Support/tateru-pro-plus/data/` independently of the `.app` bundle. Replace the `.app` to upgrade — your data carries over. Wipe the data dir for a true factory reset.

---

## Install — Windows x64

> **Unsigned during beta** — SmartScreen will warn on first launch. "More info → Run anyway" is the bypass.

### Quick install (PowerShell)

```powershell
$VERSION = "1.0.0-beta.9.7"   # ← update to current

# Download (no auth needed — public release repo)
Invoke-WebRequest -Uri "https://github.com/ushanboe/tateru-pro-releases/releases/download/v$VERSION/Tateru.Pro-$VERSION-win.zip" -OutFile "Tateru-Pro-$VERSION-win.zip"

# Extract
Expand-Archive "Tateru-Pro-$VERSION-win.zip" -DestinationPath "Tateru-Pro-$VERSION-win"

# Run
cd "Tateru-Pro-$VERSION-win\win-unpacked"
.\"Tateru Pro.exe"
```

### Quick install (GUI)

1. Open the [latest release](https://github.com/ushanboe/tateru-pro-releases/releases/latest) in Edge or Chrome
2. Click `Tateru.Pro-<version>-win.zip` to download (~230 MB)
3. Right-click the downloaded zip → **Extract All** → choose a destination folder
4. Open the extracted folder → enter the `win-unpacked` subfolder → double-click `Tateru Pro.exe`

### First launch — SmartScreen bypass

Windows Defender SmartScreen blocks unsigned binaries by default:

1. Double-click `Tateru Pro.exe` → blue *"Windows protected your PC"* dialog appears
2. Click **More info** (small text under the message)
3. Click **Run anyway** that appears
4. App launches; subsequent launches skip the warning

If SmartScreen is set to "Block" (some corporate policies), the **Run anyway** button won't appear. Workaround: right-click the .exe → Properties → tick **Unblock** at the bottom → OK → re-run.

### Where data lives

Account, projects, settings, and built APKs persist at `%APPDATA%\Tateru Pro\data\` independently of the extracted bundle. To upgrade, just delete the extracted folder and unzip the new release — your data carries over. To factory-reset, also delete `%APPDATA%\Tateru Pro\`.

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
