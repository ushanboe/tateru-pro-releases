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
| Linux x64 | `Tateru.Pro-<version>.AppImage` | ~231 MB |
| Linux x64 | `tateru-pro-plus_<version>_amd64.deb` | ~142 MB |
| macOS (Intel + Apple Silicon via Rosetta 2) | `Tateru.Pro-<version>-mac.zip` | ~221 MB |
| Windows x64 (NSIS installer — recommended) | `Tateru.Pro.Setup.<version>.exe` | ~191 MB |
| Windows x64 (portable .zip) | `Tateru.Pro-<version>-win.zip` | ~247 MB |

> **Note on filenames:** GitHub stores release assets with **dots** in place of spaces. So the file you download is `Tateru.Pro-1.0.0-beta.9.32.14.1-mac.zip` (with dots). Once unzipped, the `.app` bundle inside is named `Tateru Pro.app` (with a space) — that's normal.

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
VERSION=1.0.0-beta.9.32.14.1   # ← latest as of 2026-05-01; check the Releases page for newer
curl -LO "https://github.com/ushanboe/tateru-pro-releases/releases/download/v${VERSION}/Tateru.Pro-${VERSION}.AppImage"

# Optional: verify checksum
curl -LO "https://github.com/ushanboe/tateru-pro-releases/releases/download/v${VERSION}/SHA256SUMS-beta.9.32.14.1"
sha256sum -c SHA256SUMS-beta.9.32.14.1 --ignore-missing

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
VERSION=1.0.0-beta.9.32.14.1   # ← update to current
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
| AppImage | `rm "Tateru.Pro-1.0.0-beta.9.32.14.1.AppImage"` (just delete the file you downloaded) |
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

VERSION=1.0.0-beta.9.32.14.1   # ← update to current
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

> **Unsigned during beta** — SmartScreen will warn on first launch. Click **More info** → **Run anyway** to proceed (one-time per install). We're adding code-signing for the 1.0 release to remove this prompt entirely. Full bypass walkthrough below.

Two install paths — pick one:

| Option | Best for | Start Menu icon? | Auto-uninstall? |
|---|---|---|---|
| **A — NSIS installer** (recommended) | Most users | ✅ Yes | ✅ Settings → Apps → Uninstall |
| **B — Portable .zip** | Power users, side-by-side versions, no admin | ❌ No (manual shortcut) | ❌ Delete folder manually |

### Option A — NSIS installer (recommended; adds Start Menu icon)

#### Quick install (PowerShell)

```powershell
$VERSION = "1.0.0-beta.9.32.14.1"   # ← update to current

Invoke-WebRequest `
  -Uri "https://github.com/ushanboe/tateru-pro-releases/releases/download/v$VERSION/Tateru.Pro.Setup.$VERSION.exe" `
  -OutFile "$env:USERPROFILE\Downloads\Tateru-Pro-Setup-$VERSION.exe"

# Run the installer (SmartScreen warning will appear — see below)
& "$env:USERPROFILE\Downloads\Tateru-Pro-Setup-$VERSION.exe"
```

#### Quick install (GUI)

1. Open the [latest release](https://github.com/ushanboe/tateru-pro-releases/releases/latest) in Edge or Chrome.
2. Click `Tateru.Pro.Setup.<version>.exe` to download (~191 MB).
3. Double-click the downloaded `.exe` → SmartScreen warning appears (see bypass below).
4. The NSIS installer opens — choose installation directory (default: `%LOCALAPPDATA%\Programs\Tateru Pro`).
5. Click **Install** → wait ~30 seconds → click **Finish**.
6. Launch from **Start Menu → Tateru Pro** (proper icon + shortcut included).

### Option B — Portable .zip (no installer, no Start Menu integration)

Use this if you prefer not to run an installer, want multiple side-by-side versions, or don't have install permissions.

#### Quick install (PowerShell)

```powershell
$VERSION = "1.0.0-beta.9.32.14.1"   # ← update to current

Invoke-WebRequest `
  -Uri "https://github.com/ushanboe/tateru-pro-releases/releases/download/v$VERSION/Tateru.Pro-$VERSION-win.zip" `
  -OutFile "$env:USERPROFILE\Downloads\Tateru-Pro-$VERSION-win.zip"

Expand-Archive `
  -Path "$env:USERPROFILE\Downloads\Tateru-Pro-$VERSION-win.zip" `
  -DestinationPath "$env:LOCALAPPDATA\Programs\Tateru Pro"

& "$env:LOCALAPPDATA\Programs\Tateru Pro\win-unpacked\Tateru Pro.exe"
```

#### Quick install (GUI)

1. Open the [latest release](https://github.com/ushanboe/tateru-pro-releases/releases/latest) in Edge or Chrome.
2. Click `Tateru.Pro-<version>-win.zip` to download (~247 MB).
3. Right-click the downloaded zip → **Extract All** → choose a destination folder (e.g. `C:\Tateru Pro\`).
4. Open the extracted folder → enter the `win-unpacked` subfolder → double-click `Tateru Pro.exe`.

(Optional) Right-click `Tateru Pro.exe` → **Send to** → **Desktop (create shortcut)** for a launcher icon.

### First launch — SmartScreen bypass (both options)

Windows Defender SmartScreen blocks unsigned binaries by default. Whichever option you used, on first launch:

1. Run the `.exe` → blue *"Windows protected your PC"* dialog appears.
2. Click **More info** (small text under the message).
3. Click the **Run anyway** button that appears.
4. App launches normally; **subsequent launches skip the warning**.

If SmartScreen is set to **Block** (some corporate / enterprise policies), the **Run anyway** button won't appear. Workaround: right-click the `.exe` → **Properties** → tick **Unblock** at the bottom → **OK** → re-run.

**Why the warning?** Tateru Pro's binaries aren't yet code-signed (signing certificates cost $300–500/year for Extended Validation). We're adding **Azure Trusted Signing** in the 1.0 release — this eliminates the SmartScreen prompt entirely. For now, the bypass above is a one-time click per install.

### Uninstall — Windows

**App-only** (preserves your projects, login, and license):

| Install method | Uninstall steps |
|---|---|
| **Option A — NSIS installer** | Open **Settings → Apps → Installed apps** → find **Tateru Pro** → **⋯** → **Uninstall**. (Or via Control Panel → **Programs and Features** → **Tateru Pro** → **Uninstall**.) |
| **Option B — Portable .zip** | Delete the folder where you extracted the zip: <br>`Remove-Item -Recurse -Force "$env:LOCALAPPDATA\Programs\Tateru Pro"` |

**Factory reset** (also wipes data dir, projects, login, cached models — irreversible):

```powershell
# Stop the app if it's running
Stop-Process -Name "Tateru Pro" -Force -ErrorAction SilentlyContinue

# 1. Uninstall the app
#    - If installed via NSIS: use Settings → Apps as above (recommended — runs the proper uninstaller)
#    - If portable .zip: Remove-Item -Recurse -Force "$env:LOCALAPPDATA\Programs\Tateru Pro"

# 2. Wipe data dir (DB, projects, built APKs, license cache)
Remove-Item -Recurse -Force "$env:APPDATA\tateru-pro-plus"

# 3. Wipe cloud-client cache (JWT, offline queue)
Remove-Item -Recurse -Force "$env:USERPROFILE\.tateru-pro"
```

To also remove your stored LLM API keys: open **Credential Manager** (Start → search "Credential Manager") → **Windows Credentials** → find entries beginning with `Tateru Pro` → **Remove**.

### Known Windows-specific notes

- **NSIS installer first shipped in 9.32.13** (mod 10.119 — adds the Start Menu icon and proper Add/Remove Programs entry). Earlier versions are portable .zip only.
- **Code signing planned for 1.0** via Azure Trusted Signing — will remove the SmartScreen warning permanently.
- **No auto-updater on Windows yet** — manual download of new releases required (Releases page → download → install/extract over existing).

---

## Beta status

Currently in **closed beta**. Use an invite code from the [beta access page](https://tateru.app/beta) to register.

Tateru Pro is under active development. Patch releases ship on a roughly daily cadence as bugs surface from beta testers — see the [Releases](https://github.com/ushanboe/tateru-pro-releases/releases) page for the full history.

### Build target support

| Target | Status |
|---|---|
| Android APK | ✅ Production-ready |
| macOS `.app` | 🧪 Experimental (Mac host required) |
| iOS `.app` | ✅ Working — one-click signed iPhone install via Tateru (Mac host + Apple Developer account required) |
| iOS Simulator | ✅ Working — auto-boot + auto-launch (Mac host required) |

See [tateru.app/quick-start](https://tateru.app/quick-start) for the full walkthrough.

---

## License + privacy

The Tateru Pro app is proprietary software. By downloading and installing, you agree to the [Terms of Use](https://tateru.app/terms) and [Privacy Policy](https://tateru.app/privacy).
