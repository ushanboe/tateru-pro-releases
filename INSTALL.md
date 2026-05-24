# Tateru Pro — Install Guide (Advanced)

The one-liner installers in the [README](README.md) cover ~95% of users. This guide covers the remaining 5%: manual download, specific-version pinning, alternative install methods per OS, SHA256 verification, factory reset, and code-signing background.

> **First time?** Use the one-liner instead — it's faster, picks the right artifact for your OS, and handles all of this automatically:
> - Linux + macOS: `curl -fsSL https://tateru.app/install | bash`
> - Windows: `irm https://tateru.app/install.ps1 | iex`

---

## Why might you want the manual path?

| Reason | Pick |
|---|---|
| You want to read the install script before running it | [Review the script](#review-the-install-script-before-running-it) |
| You want a specific older version (not latest) | [Pinned-version install](#install-a-specific-version) |
| You don't trust pipe-to-shell installers | [Browser-download path](#browser-download-no-terminal) |
| You want `.deb` for apt-managed updates on Linux | [Linux Option B](#option-b--debian-package-system-install-with-menu-integration) |
| You want a portable Windows install (no admin, side-by-side) | [Windows Option B](#option-b--portable-zip-no-installer-no-start-menu-integration) |
| You want to verify the SHA256 hash before installing | [Checksum verification](#verify-sha256-checksums) |
| You want to factory-reset (wipe projects + login + keys) | [Factory reset per OS](#factory-reset-wipe-data--login--keys) |

---

## Review the install script before running it

Both install scripts are short (~150 LOC each) and source-available in the release repo. Standard "fetch + inspect + run" pattern:

```bash
# Linux + macOS
curl -fsSL https://tateru.app/install -o install.sh
less install.sh                            # inspect — exit with q
bash install.sh                            # run after reviewing
```

```powershell
# Windows
irm https://tateru.app/install.ps1 -OutFile install.ps1
notepad install.ps1                        # inspect
powershell -ExecutionPolicy Bypass -File install.ps1   # run after reviewing
```

Or read straight from the public release repo without downloading:
- https://github.com/ushanboe/tateru-pro-releases/blob/main/install.sh
- https://github.com/ushanboe/tateru-pro-releases/blob/main/install.ps1

---

## Install a specific version

Useful for testing an older release or rolling back. Add `--version=X.Y.Z` (Linux/macOS) or `-Version X.Y.Z` (Windows):

```bash
# Linux + macOS — pin to a specific release
curl -fsSL https://tateru.app/install | bash -s -- --version=1.0.0-beta.9.34.0
```

```powershell
# Windows
$installer = irm https://tateru.app/install.ps1
$installer = [scriptblock]::Create("$installer; & install -Version 1.0.0-beta.9.34.0")
& $installer
```

(The Windows syntax is awkward because `irm | iex` doesn't naturally accept flags. If you need pinned-version installs frequently on Windows, download the script + run as a file — see ["Review the install script"](#review-the-install-script-before-running-it).)

---

## Browser-download (no terminal)

If you don't want to use the terminal at all:

1. Open the [latest release](https://github.com/ushanboe/tateru-pro-releases/releases/latest) page in your browser.
2. Scroll to **Assets**. Click the file matching your OS:
   - **Linux:** `Tateru.Pro-<version>.AppImage` or `tateru-pro-plus_<version>_amd64.deb`
   - **macOS:** `Tateru.Pro-<version>-mac.zip`
   - **Windows (recommended):** `Tateru.Pro.Setup.<version>.exe`
   - **Windows (portable):** `Tateru.Pro-<version>-win.zip`
3. Follow the per-OS manual steps below.

> **Filename note:** GitHub stores release assets with **dots** in place of spaces. So the file you download is `Tateru.Pro-1.0.0-beta.9.34.2-mac.zip` (with dots). Once unzipped, the `.app` bundle inside is named `Tateru Pro.app` (with a space) — that's normal.

---

## Manual install — Linux x64

### Option A — AppImage (no install, single-file portable)

```bash
cd ~/Downloads
VERSION=1.0.0-beta.9.34.2   # ← check the Releases page for newer
curl -LO "https://github.com/ushanboe/tateru-pro-releases/releases/download/v${VERSION}/Tateru.Pro-${VERSION}.AppImage"

# Optional: verify checksum (see "Verify SHA256 checksums" below)

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
VERSION=1.0.0-beta.9.34.2   # ← check the Releases page for newer
curl -LO "https://github.com/ushanboe/tateru-pro-releases/releases/download/v${VERSION}/tateru-pro-plus_${VERSION}_amd64.deb"
sudo apt install "./tateru-pro-plus_${VERSION}_amd64.deb"

# Then launch from your application menu, or:
tateru-pro-plus
```

---

## Manual install — macOS (Intel + Apple Silicon)

> **Unsigned during beta** — macOS Gatekeeper will warn on first launch. Right-click → Open bypasses cleanly. See [MACOS_INSTALL.md](MACOS_INSTALL.md) for the full Mac-specific guide.

### Terminal install

```bash
osascript -e 'quit app "Tateru Pro"' 2>/dev/null   # quit any running version

VERSION=1.0.0-beta.9.34.2   # ← check the Releases page for newer
cd ~/Downloads
curl -LO "https://github.com/ushanboe/tateru-pro-releases/releases/download/v${VERSION}/Tateru.Pro-${VERSION}-mac.zip"
unzip -q "Tateru.Pro-${VERSION}-mac.zip"
mv "Tateru Pro.app" /Applications/
xattr -dr com.apple.quarantine "/Applications/Tateru Pro.app"   # strip Gatekeeper quarantine
open "/Applications/Tateru Pro.app"
```

### GUI install

1. Open the [latest release](https://github.com/ushanboe/tateru-pro-releases/releases/latest) in Safari.
2. Click `Tateru.Pro-<version>-mac.zip` to download.
3. Double-click the downloaded zip in Finder → produces `Tateru Pro.app`.
4. Drag `Tateru Pro.app` into **Applications**.
5. **Right-click** the app → **Open** → click **Open** in the warning (one-time only — subsequent launches work via double-click).

---

## Manual install — Windows x64

> **Unsigned during beta** — SmartScreen will warn on first launch. Click **More info** → **Run anyway** to proceed (one-time per install). We're adding code-signing for the 1.0 release to remove this prompt entirely. Full bypass walkthrough below.

Two install paths — pick one:

| Option | Best for | Start Menu icon? | Auto-uninstall? |
|---|---|---|---|
| **A — NSIS installer** (recommended) | Most users | ✅ Yes | ✅ Settings → Apps → Uninstall |
| **B — Portable .zip** | Power users, side-by-side versions, no admin | ❌ No (manual shortcut) | ❌ Delete folder manually |

### Option A — NSIS installer (recommended; adds Start Menu icon)

#### PowerShell install

```powershell
$VERSION = "1.0.0-beta.9.34.2"   # ← check the Releases page for newer

Invoke-WebRequest `
  -Uri "https://github.com/ushanboe/tateru-pro-releases/releases/download/v$VERSION/Tateru.Pro.Setup.$VERSION.exe" `
  -OutFile "$env:USERPROFILE\Downloads\Tateru-Pro-Setup-$VERSION.exe"

# Run the installer (SmartScreen warning will appear — see below)
& "$env:USERPROFILE\Downloads\Tateru-Pro-Setup-$VERSION.exe"
```

#### GUI install

1. Open the [latest release](https://github.com/ushanboe/tateru-pro-releases/releases/latest) in Edge or Chrome.
2. Click `Tateru.Pro.Setup.<version>.exe` to download (~191 MB).
3. Double-click the downloaded `.exe` → SmartScreen warning appears (see bypass below).
4. The NSIS installer opens — choose installation directory (default: `%LOCALAPPDATA%\Programs\Tateru Pro`).
5. Click **Install** → wait ~30 seconds → click **Finish**.
6. Launch from **Start Menu → Tateru Pro** (proper icon + shortcut included).

### Option B — Portable .zip (no installer, no Start Menu integration)

Use this if you prefer not to run an installer, want multiple side-by-side versions, or don't have install permissions.

#### PowerShell install

```powershell
$VERSION = "1.0.0-beta.9.34.2"   # ← check the Releases page for newer

Invoke-WebRequest `
  -Uri "https://github.com/ushanboe/tateru-pro-releases/releases/download/v$VERSION/Tateru.Pro-$VERSION-win.zip" `
  -OutFile "$env:USERPROFILE\Downloads\Tateru-Pro-$VERSION-win.zip"

Expand-Archive `
  -Path "$env:USERPROFILE\Downloads\Tateru-Pro-$VERSION-win.zip" `
  -DestinationPath "$env:LOCALAPPDATA\Programs\Tateru Pro"

& "$env:LOCALAPPDATA\Programs\Tateru Pro\win-unpacked\Tateru Pro.exe"
```

#### GUI install

1. Open the [latest release](https://github.com/ushanboe/tateru-pro-releases/releases/latest) in Edge or Chrome.
2. Click `Tateru.Pro-<version>-win.zip` to download (~247 MB).
3. Right-click the downloaded zip → **Extract All** → choose a destination folder (e.g. `C:\Tateru Pro\`).
4. Open the extracted folder → enter the `win-unpacked` subfolder → double-click `Tateru Pro.exe`.

(Optional) Right-click `Tateru Pro.exe` → **Send to** → **Desktop (create shortcut)** for a launcher icon.

### Windows first launch — SmartScreen bypass

Windows Defender SmartScreen blocks unsigned binaries by default. Whichever option you used, on first launch:

1. Run the `.exe` → blue *"Windows protected your PC"* dialog appears.
2. Click **More info** (small text under the message).
3. Click the **Run anyway** button that appears.
4. App launches normally; **subsequent launches skip the warning**.

If SmartScreen is set to **Block** (some corporate / enterprise policies), the **Run anyway** button won't appear. Workaround: right-click the `.exe` → **Properties** → tick **Unblock** at the bottom → **OK** → re-run.

**Why the warning?** Tateru Pro's binaries aren't yet code-signed (signing certificates cost $300–500/year for Extended Validation). We're adding **Azure Trusted Signing** in the 1.0 release — this eliminates the SmartScreen prompt entirely. For now, the bypass above is a one-time click per install.

---

## Verify SHA256 checksums

Every release ships a `SHA256SUMS-<short-version>` file. Compare the downloaded artifact against it:

### Linux + macOS

```bash
VERSION=1.0.0-beta.9.34.2
SHORT=beta.9.34.2
cd ~/Downloads
curl -LO "https://github.com/ushanboe/tateru-pro-releases/releases/download/v${VERSION}/SHA256SUMS-${SHORT}"
sha256sum -c "SHA256SUMS-${SHORT}" --ignore-missing
# OR on macOS: shasum -a 256 -c "SHA256SUMS-${SHORT}" --ignore-missing
```

A clean install prints `<filename>: OK` for each matching file. Mismatches print `FAILED` + stop — DO NOT install if the hash doesn't match.

### Windows (PowerShell)

```powershell
$VERSION = "1.0.0-beta.9.34.2"
$expected = "<paste-hash-from-SHA256SUMS-file>"
$actual = (Get-FileHash "Tateru.Pro.Setup.$VERSION.exe" -Algorithm SHA256).Hash.ToLower()
if ($actual -eq $expected) { "OK" } else { "MISMATCH — DO NOT INSTALL" }
```

---

## Uninstall — manual (app-only)

The one-liner uninstallers in the [README](README.md#uninstall-with-one-line) are the recommended path. If you want to do it by hand:

### Linux (app-only — preserves projects + login)

| Install method | Remove command |
|---|---|
| AppImage | `rm ~/Applications/Tateru\ Pro-*.AppImage` (delete the file) |
| Debian package | `sudo apt remove tateru-pro-plus` |

### macOS (app-only)

```bash
osascript -e 'quit app "Tateru Pro"' 2>/dev/null
rm -rf "/Applications/Tateru Pro.app"
```

Or via Finder: drag `Tateru Pro` from Applications → Trash.

### Windows (app-only)

| Install method | Uninstall steps |
|---|---|
| **NSIS installer** | **Settings → Apps → Installed apps** → find **Tateru Pro** → **⋯** → **Uninstall**. Or Control Panel → Programs and Features → Tateru Pro → Uninstall. |
| **Portable .zip** | Delete the extracted folder: `Remove-Item -Recurse -Force "$env:LOCALAPPDATA\Programs\Tateru Pro"` |

---

## Factory reset (wipe data + login + keys)

> **⚠ Irreversible.** Wipes your generated projects, built APKs, SQLite DB, login, and license cache. Use this only when starting completely fresh (testing the onboarding flow, or recovering from a corrupted install).

The one-liner uninstallers in the [README](README.md#uninstall-with-one-line) include an interactive "wipe my data" option — easier than the manual commands below. The manual route below is provided as documentation.

### Linux (factory reset)

```bash
# 1. Quit the app + lingering Tateru-spawned processes
pkill -f "Tateru Pro" 2>/dev/null
pkill -f tateru-pro-plus 2>/dev/null
pkill -f "next dev" 2>/dev/null  # GreenThumb preview servers

# 2. Remove the app
sudo apt remove tateru-pro-plus 2>/dev/null   # if installed via .deb
rm -f ~/Applications/Tateru\ Pro-*.AppImage   # if AppImage

# 3. Wipe data dir + caches
rm -rf "$HOME/.config/tateru-pro-plus"
rm -rf "$HOME/.cache/tateru-pro-plus"
rm -rf "$HOME/.cache/tateru-pro-plus-updater"
rm -rf "$HOME/.tateru-pro"

# 4. Wipe Apps-menu integration left by AppImage first launch
rm -f ~/.local/share/applications/tateru-pro-plus.desktop
find ~/.local/share/icons/hicolor -name "tateru-pro-plus.*" -delete 2>/dev/null

# 5. Wipe keyring entries (LLM API keys)
# GNOME: open Seahorse / Passwords and Keys → search "tateru" → delete
# KDE:   open KWallet Manager → search "tateru" → delete
```

### macOS (factory reset)

```bash
osascript -e 'quit app "Tateru Pro"' 2>/dev/null
pkill -f "Tateru Pro" 2>/dev/null
rm -rf "/Applications/Tateru Pro.app"
rm -rf "$HOME/Library/Application Support/tateru-pro-plus"
rm -rf "$HOME/Library/Application Support/Tateru Pro"   # legacy path
rm -rf "$HOME/Library/Caches/com.tateru.pro.plus"
rm -rf "$HOME/Library/Caches/tateru-pro-plus"
rm -rf "$HOME/Library/Logs/tateru-pro-plus"
rm -rf "$HOME/Library/Preferences/com.tateru.pro.plus.plist"
rm -rf "$HOME/Library/Saved Application State/com.tateru.pro.plus.savedState"
rm -rf "$HOME/.tateru-pro"
defaults delete com.tateru.pro.plus 2>/dev/null
```

To also remove your stored LLM API keys: open **Keychain Access.app** → search `tateru` → delete the matching entries.

### Windows (factory reset)

```powershell
# 1. Stop the app + lingering processes
Stop-Process -Name "Tateru Pro" -Force -ErrorAction SilentlyContinue

# 2. Uninstall the app
#    - If installed via NSIS: use Settings → Apps as above (recommended — runs the proper uninstaller)
#    - If portable .zip: Remove-Item -Recurse -Force "$env:LOCALAPPDATA\Programs\Tateru Pro"

# 3. Wipe data dir (DB, projects, built APKs, license cache)
Remove-Item -Recurse -Force "$env:APPDATA\tateru-pro-plus"

# 4. Wipe cloud-client cache (JWT, offline queue)
Remove-Item -Recurse -Force "$env:USERPROFILE\.tateru-pro"
```

To also remove your stored LLM API keys: open **Credential Manager** (Start → search "Credential Manager") → **Windows Credentials** → find entries beginning with `Tateru Pro` → **Remove**.

---

## What's in each release

| Platform | File | Approx size |
|---|---|---|
| Linux x64 | `Tateru.Pro-<version>.AppImage` | ~231 MB |
| Linux x64 | `tateru-pro-plus_<version>_amd64.deb` | ~142 MB |
| macOS (Intel + Apple Silicon via Rosetta 2) | `Tateru.Pro-<version>-mac.zip` | ~221 MB |
| Windows x64 (NSIS installer — recommended) | `Tateru.Pro.Setup.<version>.exe` | ~191 MB |
| Windows x64 (portable .zip) | `Tateru.Pro-<version>-win.zip` | ~247 MB |

> **Filename note:** GitHub stores release assets with **dots** in place of spaces. So the file you download is `Tateru.Pro-1.0.0-beta.9.34.2-mac.zip` (with dots). Once unzipped, the `.app` bundle inside is named `Tateru Pro.app` (with a space) — that's normal.

Every release also ships:
- `SHA256SUMS-<short-version>` — hashes for all 5 binaries
- (Future) signed PDFs of the Quick Start + User Manual + FAQ — requires `pandoc` on the build host, currently skipped per release notes

---

## Known platform notes

- **NSIS installer first shipped in 9.32.13** (mod 10.119 — adds the Start Menu icon and proper Add/Remove Programs entry). Earlier versions are portable `.zip` only.
- **macOS code signing planned for 1.0** — Apple Developer cert active; just needs the build pipeline wired in.
- **Windows code signing planned for 1.0** via Azure Trusted Signing — eliminates SmartScreen warning permanently.
- **No auto-updater on Windows yet** — re-run the one-liner or manually download new releases (the one-liner picks latest, so it's the path of least friction).
- **Linux + macOS auto-update is via the one-liner** — re-running it picks up new versions automatically. (electron-updater is wired but the one-liner is more robust for unsigned-binary scenarios.)

---

## Where to go next

- **Quick Start** (subscribed-user walkthrough): https://tateru.app/quick-start
- **User Manual** (in-app — Help → User Manual once installed): bundled in every release
- **Troubleshooting recipes**: bundled in every release as TROUBLESHOOTING.md, also at https://tateru.app/troubleshooting
- **Support**: support@tateru.app
- **Bug reports**: support@tateru.app or in-app Send Feedback
