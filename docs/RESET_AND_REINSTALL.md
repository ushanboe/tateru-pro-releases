---
**App:** Tateru Pro
**Version:** 1.0.0-beta.9.34.15
**Owner:** KangaBlue.au
**Contact:** support@tateru.app
**Last updated:** 2026-06-08
---

# Reset and Reinstall — Complete Fresh-Install Guide

Step-by-step recipes for **completely removing Tateru Pro and all its build
dependencies** (Flutter SDK, Android SDK + Studio, Java JDK, Git, Node.js), then
reinstalling cleanly. Useful for:

- Testing a brand-new install path before the BetaList traffic lands
- Recovering from a corrupted SDK install that auto-detect can't fix
- Switching machines and wanting to confirm Tateru works on a clean OS
- Debugging "but it works on my machine" issues

## ⚠ Required prerequisites (install BEFORE Tateru)

After completing this reset, you'll reinstall four things in order: the
four required dependencies FIRST, then Tateru. Tateru's setup wizard
refuses to launch the pipeline if any are missing.

| Required | Version | Install from |
|---|---|---|
| **Flutter SDK** | **3.41.9** (NOT 3.44.0 — known `flutter create` bug) | https://docs.flutter.dev/get-started/install |
| **Android Studio** | Latest stable — **must open once after install** to download SDK (~3 GB) | https://developer.android.com/studio |
| **Java JDK** | Temurin 17 LTS (or accept Android Studio's bundled JBR) | https://adoptium.net/temurin/releases/ |
| **Git** | Latest | https://git-scm.com/downloads |
| **Node.js + npm** | LTS (18 or newer) — required for GreenThumb (marketing website + docs) | https://nodejs.org/en/download |
| **Windows only: Developer Mode** | Must be **ON** — Flutter needs it for symlink support, or APK builds fail | Settings → Privacy & security → For developers → **Developer Mode = On** |

**Common gotchas:**

- **Flutter 3.44.0 is broken** — has a `flutter create` pubspec.lock-path bug that crashes every first APK build. Pin to 3.41.9.
- **Android Studio: open it once after install** — the IDE is just the shell; the actual SDK is downloaded by the first-launch wizard. Skip this step and Tateru's detection will fail.
- **Java JDK is optional if Android Studio is installed** — Tateru auto-detects Android Studio's bundled JBR.
- **Node.js is only needed for GreenThumb** — the marketing-website + docs generator runs `npm install` + a Next.js preview server. The Flutter app build itself does NOT need Node. Install it before using GreenThumb.
- **Windows Developer Mode is required to build** — on a fresh Windows install the first build shows a symlink-permission warning until Developer Mode is on (link above). This is a Flutter requirement.

> ⚠ Most beta testers will **NOT** need a full reset. Tateru's SetupWizard
> + Settings → SDK Paths can detect, persist, and self-heal stale paths.
> Read [Troubleshooting](TROUBLESHOOTING.md) first — the common issues
> have one-line fixes that don't require a full wipe.

> 💡 **Lighter alternative — in-app reset.** Before reinstalling, try
> **Settings → Privacy & Reset**. It wipes your saved API keys + the local
> database so you start clean, while **keeping your projects and built
> APKs**. This clears stale credentials / corrupted DB state without
> touching the SDKs or reinstalling Tateru — often all you need.

---

## When to use this guide

| Situation | Recommendation |
|---|---|
| First-time install, just downloaded Tateru | ❌ Don't — follow [Quick Start](QUICK_START.md) instead |
| SetupWizard says "Flutter not found" but I have it installed | ❌ Don't — open Settings → SDK Paths → manually set `FLUTTER_PATH` |
| App builds fine but APK doesn't install on phone | ❌ Don't — see [Troubleshooting → ADB issues](TROUBLESHOOTING.md) |
| I want to verify a fresh BetaList signup flow works | ✅ Yes — full reset |
| Flutter / Android SDK install got into a weird state I can't fix | ✅ Yes — wipe the affected SDK only (Phase 2 or 3) |
| Tateru won't launch at all (no window, no error) | ⚠ Try Phase 1 only (just remove Tateru + its userData) before touching SDKs |

---

## What gets removed

| Phase | What | Reversible? |
|---|---|---|
| 1 | Tateru Pro app + userData (settings, saved API keys, project DB) | Easy — projects can be exported first |
| 2 | Flutter SDK + Pub cache | Easy — re-download from flutter.dev |
| 3 | Android SDK + Android Studio + Gradle cache | Medium — Android Studio re-download is ~3GB |
| 4 | Java JDK (Adoptium / Oracle / Microsoft / Zulu) — **OPTIONAL** | Easy — re-download from adoptium.net |

> ⚠️ **Back up your projects FIRST.** If you have apps you've built and want
> to keep, open Tateru → My Apps → click each project → "Export" button. Save
> the `.tateru-project` files somewhere outside the userData dir. After the
> fresh install you can use **Build Modes → Import Project** to restore them.
>
> If you don't, your generated source code + APKs + spec data are GONE.

---

# Phase 1: Uninstall Tateru Pro

## Windows (NSIS installer or .zip)

**If you installed via the NSIS installer (`Tateru Pro Setup 1.0.0-beta.X.X.exe`):**

```powershell
# Run PowerShell as Administrator
Get-Package "Tateru Pro" -ErrorAction SilentlyContinue | Uninstall-Package

# Or via Settings → Apps → Tateru Pro → Uninstall (GUI)
```

**If you installed via the .zip (extracted somewhere manually):**

Just delete the extracted folder — there's no installed registry entry.

**Either way, delete userData** (uninstaller doesn't touch it by default). **Run PowerShell as Administrator** for the cleanest result:

```powershell
# 1. KILL all Tateru processes first (don't skip — file locks will prevent the delete)
taskkill /F /IM "Tateru Pro.exe" /T 2>$null
taskkill /F /IM "tateru-pro-plus.exe" /T 2>$null
Get-Process -Name "Tateru*", "tateru*", "electron" -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 3

# 2. Delete userData WITH visible errors
$path = "$env:APPDATA\tateru-pro-plus"
Remove-Item -Recurse -Force $path -Verbose -ErrorAction Continue

# 3. If step 2 left files behind (lock errors), fall back to cmd rmdir (more aggressive)
if (Test-Path $path) {
    Write-Host "Remove-Item left files behind. Trying cmd rmdir..." -ForegroundColor Yellow
    cmd /c "rmdir /S /Q `"$path`""
}

# 4. Verify (should be False)
Test-Path $path
```

⚠ **If step 2 throws `The process cannot access the file because it is being used by another process`** → there's a stale process holding handles on the userData files. **Reboot Windows** to guarantee no stale handles, then retry from step 1.

The userData folder contains:
- `.env` — your saved API keys, `FLUTTER_PATH`, `ANDROID_HOME`, Telegram bot credentials
- `tateru.db` — projects + license cache + agent logs
- `data/projects/` — generated Flutter project source code
- `data/output_apps/` — built APK files

---

## macOS (.zip)

Tateru on macOS ships as a `.zip` containing `Tateru Pro.app`. Use the
provided uninstall script for the cleanest removal:

```bash
# Download from the release page
curl -LO https://github.com/ushanboe/tateru-pro-releases/raw/main/scripts/uninstall-macos.sh
chmod +x uninstall-macos.sh

# Run with --purge to also wipe userData
./uninstall-macos.sh --purge
```

**Manual removal** (if the script isn't available):

```bash
# Quit the app
osascript -e 'tell application "Tateru Pro" to quit' 2>/dev/null
pkill -9 -f "Tateru Pro" 2>/dev/null
sleep 2

# Remove the app
rm -rf "/Applications/Tateru Pro.app"

# Remove userData (saved settings, API keys, projects)
rm -rf "$HOME/Library/Application Support/tateru-pro-plus"

# Optional: remove other Electron-related state
rm -rf "$HOME/Library/Logs/tateru-pro-plus"
rm -rf "$HOME/Library/Caches/tateru-pro-plus"
rm -rf "$HOME/Library/Caches/tateru-pro-plus.ShipIt"
rm -rf "$HOME/Library/Preferences/tateru-pro-plus.plist"
```

---

## Linux — .deb (Debian / Ubuntu / Mint)

```bash
# Apt-managed uninstall (preferred)
sudo apt remove tateru-pro-plus

# OR via dpkg directly
sudo dpkg -r tateru-pro-plus

# Remove userData
rm -rf "$HOME/.config/tateru-pro-plus"
```

**For the cleanest removal**, use the provided script:

```bash
curl -LO https://github.com/ushanboe/tateru-pro-releases/raw/main/scripts/uninstall-linux.sh
chmod +x uninstall-linux.sh
./uninstall-linux.sh --purge  # --purge also wipes userData
```

---

## Linux — AppImage

AppImages are portable — there's no installer state to manage:

```bash
# Delete the file you downloaded
rm "$HOME/Downloads/Tateru.Pro-1.0.0-beta.X.X.AppImage"

# Remove first-launch integration files
# (the .desktop entry + icons Tateru auto-installed)
rm -f "$HOME/.local/share/applications/tateru-pro-plus.desktop"
rm -f "$HOME/.local/share/icons/hicolor/"*/apps/tateru-pro-plus.png

# Refresh the desktop database so the menu entry disappears
update-desktop-database "$HOME/.local/share/applications" 2>/dev/null
gtk-update-icon-cache "$HOME/.local/share/icons/hicolor" 2>/dev/null

# Remove userData
rm -rf "$HOME/.config/tateru-pro-plus"
```

---

# Phase 2: Remove Flutter SDK

## Windows

```powershell
# Remove Flutter from all common install locations
Remove-Item -Recurse -Force "C:\flutter" -ErrorAction SilentlyContinue
Remove-Item -Recurse -Force "C:\src\flutter" -ErrorAction SilentlyContinue
Remove-Item -Recurse -Force "$env:USERPROFILE\flutter" -ErrorAction SilentlyContinue
Remove-Item -Recurse -Force "$env:USERPROFILE\development\flutter" -ErrorAction SilentlyContinue
Remove-Item -Recurse -Force "$env:LOCALAPPDATA\flutter" -ErrorAction SilentlyContinue

# Remove Pub cache (downloaded Flutter packages — ~few hundred MB)
Remove-Item -Recurse -Force "$env:LOCALAPPDATA\Pub\Cache" -ErrorAction SilentlyContinue

# Strip Flutter from User PATH
$path = [Environment]::GetEnvironmentVariable("PATH", "User")
$cleaned = ($path -split ';' | Where-Object {
  $_ -notmatch 'flutter' -and $_ -notmatch 'Pub\\Cache'
}) -join ';'
[Environment]::SetEnvironmentVariable("PATH", $cleaned, "User")

# Strip FLUTTER_PATH env var
[Environment]::SetEnvironmentVariable("FLUTTER_PATH", $null, "User")
```

---

## macOS

```bash
# Remove Flutter from common install locations
rm -rf "$HOME/flutter"
rm -rf "$HOME/development/flutter"
rm -rf "/opt/flutter"
rm -rf "/usr/local/flutter"

# Remove Pub cache
rm -rf "$HOME/.pub-cache"

# Strip Flutter from shell init files
for rc in ~/.zshrc ~/.bashrc ~/.bash_profile ~/.profile ~/.config/fish/config.fish; do
  [ -f "$rc" ] && sed -i.bak '/flutter\/bin/d' "$rc" 2>/dev/null
done

# Apply (or just restart Terminal)
source ~/.zshrc 2>/dev/null || source ~/.bashrc 2>/dev/null || true
```

---

## Linux

```bash
# Remove Flutter from common install locations
rm -rf "$HOME/flutter"
rm -rf "$HOME/development/flutter"
rm -rf "$HOME/snap/flutter"      # if installed via snap (also: sudo snap remove flutter)
rm -rf "/opt/flutter"
rm -rf "/usr/local/flutter"

# Remove Pub cache
rm -rf "$HOME/.pub-cache"

# Strip Flutter from shell init files
for rc in ~/.bashrc ~/.zshrc ~/.profile ~/.config/fish/config.fish; do
  [ -f "$rc" ] && sed -i.bak '/flutter\/bin/d' "$rc" 2>/dev/null
done

# If Flutter was installed via snap
sudo snap remove flutter 2>/dev/null || true

# Apply (or just open a new terminal)
source ~/.bashrc 2>/dev/null || true
```

---

# Phase 3: Remove Android SDK + Android Studio

## Windows

```powershell
# Remove Android SDK directories
Remove-Item -Recurse -Force "$env:LOCALAPPDATA\Android" -ErrorAction SilentlyContinue
Remove-Item -Recurse -Force "C:\Android" -ErrorAction SilentlyContinue
Remove-Item -Recurse -Force "$env:USERPROFILE\.android" -ErrorAction SilentlyContinue
Remove-Item -Recurse -Force "$env:USERPROFILE\.gradle" -ErrorAction SilentlyContinue

# Uninstall Android Studio
Get-Package "Android Studio" -ErrorAction SilentlyContinue | Uninstall-Package
# OR via Settings → Apps → Android Studio → Uninstall (GUI)

# Strip ANDROID_HOME / ANDROID_SDK_ROOT env vars
[Environment]::SetEnvironmentVariable("ANDROID_HOME", $null, "User")
[Environment]::SetEnvironmentVariable("ANDROID_SDK_ROOT", $null, "User")

# Strip Android SDK paths from User PATH
$path = [Environment]::GetEnvironmentVariable("PATH", "User")
$cleaned = ($path -split ';' | Where-Object {
  $_ -notmatch '[Aa]ndroid\\[Ss]dk' -and
  $_ -notmatch 'platform-tools' -and
  $_ -notmatch 'cmdline-tools' -and
  $_ -notmatch 'build-tools'
}) -join ';'
[Environment]::SetEnvironmentVariable("PATH", $cleaned, "User")
```

---

## macOS

```bash
# Remove Android SDK + Studio
rm -rf "$HOME/Library/Android/sdk"
rm -rf "$HOME/Library/Caches/AndroidStudio"
rm -rf "$HOME/Library/Application Support/Google/AndroidStudio"
rm -rf "$HOME/Library/Preferences/com.google.android.studio.plist"
rm -rf "$HOME/.android"
rm -rf "$HOME/.gradle"

# Drag /Applications/Android Studio.app to Trash
# Or via command line:
rm -rf "/Applications/Android Studio.app"

# Strip ANDROID_HOME / ANDROID_SDK_ROOT from shell init
for rc in ~/.zshrc ~/.bashrc ~/.bash_profile ~/.profile; do
  [ -f "$rc" ] && sed -i.bak '/ANDROID_HOME/d;/ANDROID_SDK_ROOT/d;/android.*sdk/d' "$rc" 2>/dev/null
done

# If you installed Android SDK via Homebrew
brew uninstall --cask android-studio 2>/dev/null || true
brew uninstall --cask android-sdk 2>/dev/null || true
brew uninstall --cask android-commandlinetools 2>/dev/null || true
brew uninstall --cask android-platform-tools 2>/dev/null || true
```

---

## Linux

```bash
# Remove Android SDK directories
rm -rf "$HOME/Android"
rm -rf "$HOME/android-sdk"
rm -rf "/opt/android-sdk"
rm -rf "/usr/lib/android-sdk"
rm -rf "$HOME/.android"
rm -rf "$HOME/.gradle"

# Uninstall Android Studio
# If installed via .tar.gz / .zip: delete the extracted folder
rm -rf "$HOME/android-studio"
rm -rf "/opt/android-studio"

# If installed via snap
sudo snap remove android-studio 2>/dev/null || true

# If installed via apt (Ubuntu PPA)
sudo apt remove android-studio 2>/dev/null || true

# Strip ANDROID_HOME / ANDROID_SDK_ROOT from shell init
for rc in ~/.bashrc ~/.zshrc ~/.profile ~/.config/fish/config.fish; do
  [ -f "$rc" ] && sed -i.bak '/ANDROID_HOME/d;/ANDROID_SDK_ROOT/d;/android.*sdk/d' "$rc" 2>/dev/null
done

# Remove Android Studio's .desktop entry (if installed via tarball)
rm -f "$HOME/.local/share/applications/jetbrains-studio.desktop"
rm -f "/usr/share/applications/jetbrains-studio.desktop"
```

---

# Phase 4: Remove Java JDK — OPTIONAL

⚠ **Skip this if you use Java for OTHER things** (Minecraft, IntelliJ for
non-Android development, server work, etc.). Tateru's SetupWizard will detect
existing Java fine — you don't need to remove it just to test a fresh install.

Only do Phase 4 if you specifically want to test the "no Java at all" path
of the SetupWizard.

## Windows

```powershell
# Uninstall standalone JDKs (Adoptium / Oracle / Microsoft / Zulu / Corretto)
Get-Package "*JDK*" -ErrorAction SilentlyContinue | Uninstall-Package
Get-Package "Eclipse Temurin*" -ErrorAction SilentlyContinue | Uninstall-Package
Get-Package "Java*" -ErrorAction SilentlyContinue | Uninstall-Package

# Strip JAVA_HOME
[Environment]::SetEnvironmentVariable("JAVA_HOME", $null, "User")
[Environment]::SetEnvironmentVariable("JAVA_HOME", $null, "Machine")

# Strip Java from PATH
$path = [Environment]::GetEnvironmentVariable("PATH", "User")
$cleaned = ($path -split ';' | Where-Object { $_ -notmatch 'jdk' -and $_ -notmatch 'java' }) -join ';'
[Environment]::SetEnvironmentVariable("PATH", $cleaned, "User")
```

---

## macOS

```bash
# Find installed JDKs
/usr/libexec/java_home -V 2>&1

# Remove specific JDK (replace path with what java_home showed)
sudo rm -rf "/Library/Java/JavaVirtualMachines/temurin-17.jdk"
sudo rm -rf "/Library/Java/JavaVirtualMachines/jdk-17.jdk"

# Or remove ALL Java installs
sudo rm -rf "/Library/Java/JavaVirtualMachines/"*

# If installed via Homebrew
brew uninstall --cask temurin 2>/dev/null || true
brew uninstall openjdk 2>/dev/null || true

# Strip JAVA_HOME from shell init
for rc in ~/.zshrc ~/.bashrc ~/.bash_profile ~/.profile; do
  [ -f "$rc" ] && sed -i.bak '/JAVA_HOME/d' "$rc" 2>/dev/null
done
```

---

## Linux

```bash
# If installed via apt
sudo apt remove default-jdk default-jre openjdk-* 2>/dev/null

# If installed manually
sudo rm -rf "/usr/lib/jvm"
sudo rm -rf "/opt/java"

# Strip JAVA_HOME from shell init
for rc in ~/.bashrc ~/.zshrc ~/.profile; do
  [ -f "$rc" ] && sed -i.bak '/JAVA_HOME/d' "$rc" 2>/dev/null
done
```

---

# Phase 5: Verify clean state

After completing the phases you wanted, verify Tateru's dependencies are
truly gone before reinstalling. Run these checks in a **fresh terminal**
(env-var changes don't propagate to existing shells).

## Windows (PowerShell)

```powershell
where.exe flutter         # → "INFO: Could not find files for the given pattern(s)"
where.exe adb             # → same
where.exe java            # → same (or shows non-Android JDK location if you skipped Phase 4)

Test-Path "$env:APPDATA\tateru-pro-plus"   # → False
Test-Path "$env:LOCALAPPDATA\Android\Sdk"  # → False
Test-Path "C:\flutter"                     # → False
Test-Path "$env:USERPROFILE\flutter"       # → False

# Confirm env vars are gone
[Environment]::GetEnvironmentVariable("FLUTTER_PATH", "User")   # → (blank)
[Environment]::GetEnvironmentVariable("ANDROID_HOME", "User")   # → (blank)
[Environment]::GetEnvironmentVariable("JAVA_HOME", "User")      # → (blank)
```

## macOS

```bash
which flutter      # → flutter not found
which adb          # → adb not found
which java         # → java not found (or non-Android system Java if Phase 4 skipped)
ls /Applications | grep -i 'tateru\|android'  # → no output
ls "$HOME/Library/Application Support/" | grep tateru-pro-plus  # → no output
```

## Linux

```bash
which flutter      # → flutter not found
which adb          # → adb not found
which java         # → java not found (or non-Android system Java if Phase 4 skipped)
ls "$HOME/.config/" | grep tateru-pro-plus    # → no output
[ -d "$HOME/Android/Sdk" ] && echo "STILL THERE" || echo "GONE"  # → GONE
[ -d "$HOME/flutter" ] && echo "STILL THERE" || echo "GONE"      # → GONE
```

---

# Phase 6: Restart + reinstall

## Restart first

Environment-variable changes don't always propagate to running processes
until you start a new session. Strongly recommended:

- **Windows:** restart the computer (or sign out + sign in)
- **macOS:** close all terminals, optionally restart
- **Linux:** open a fresh terminal (or restart for safety)

## Now install Tateru fresh

1. Download the platform-appropriate installer from
   https://github.com/ushanboe/tateru-pro-releases/releases/latest
   - **Windows:** `Tateru Pro Setup 1.0.0-beta.X.X.exe` (NSIS installer, recommended)
     or `Tateru Pro-1.0.0-beta.X.X-win.zip` (portable extract-anywhere)
   - **macOS:** `Tateru Pro-1.0.0-beta.X.X-mac.zip`
   - **Linux Debian/Ubuntu:** `tateru-pro-plus_1.0.0-beta.X.X_amd64.deb`
     or `Tateru Pro-1.0.0-beta.X.X.AppImage` (portable, no install needed)
2. Install:
   - **Windows NSIS:** run the .exe. SmartScreen "Windows protected your PC" →
     **More info** → **Run anyway** (the binary is unsigned beta).
   - **Windows .zip:** unzip anywhere, run `Tateru Pro.exe` inside.
   - **macOS:** unzip the .zip → drag `Tateru Pro.app` to `/Applications/`. First
     launch may need **right-click → Open** to bypass Gatekeeper (unsigned beta).
   - **Linux .deb:** `sudo dpkg -i tateru-pro-plus_*.deb` then launch from Apps menu.
   - **Linux AppImage:** `chmod +x Tateru.Pro-*.AppImage` then run directly.
3. Walk through the **SetupWizard**:
   - Welcome → Flutter step
   - Click **`✨ Install Flutter for me`** (auto-downloads pinned Flutter 3.41.9 + installs to standard path + auto-saves `FLUTTER_PATH`)
   - Android step → click **`Open Android Studio download page`** → install Android Studio → ⚠ **open Android Studio once to download the SDK** (~3GB) → come back to Tateru → click **Check Again**
   - Java step usually auto-detects from Android Studio's bundled JBR
   - AI Provider step → paste your Anthropic + OpenAI keys → Test → Save
   - Finish → Register (if fresh BetaList signup, use your invite code)

---

# Troubleshooting

## "I removed Flutter but `where flutter` still finds it"

Open a **new terminal** — env-var changes don't propagate to existing shells.

If still finds it: there's a system-level install you missed. Look at the
path output of `where flutter` (Windows) or `which flutter` (Mac/Linux) —
that's the location to remove.

## "Uninstall script says permission denied"

- **Windows:** run PowerShell **as Administrator**
- **macOS / Linux:** prepend `sudo` (or for userData paths, just check ownership)

## "I deleted everything but Tateru's wizard still shows the old Flutter path"

Tateru caches `FLUTTER_PATH` in its userData `.env` file. The Phase 1 step
to delete userData (`$APPDATA\tateru-pro-plus` on Windows, etc.) removes
this — but if you skipped that step, do it now. Then relaunch Tateru.

## "After reset, Tateru's `✨ Install Flutter for me` button fails"

Most common cause: no disk space at the destination. The Flutter SDK needs
~1.5 GB (download + extracted). Check free space at:
- **Windows:** `C:\` (Tateru installs to `C:\flutter\`)
- **macOS:** `~/development/` (Tateru installs to `~/development/flutter/`)
- **Linux:** `$HOME` (Tateru installs to `~/flutter/`)

Second-most-common cause: corporate firewall blocking
`storage.googleapis.com`. Confirm with:

```bash
curl -I https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.41.9-stable.tar.xz
```

If you get 200 OK, the CDN is reachable. If timeouts or 403 → firewall.

## "I wiped Java but Android Studio brings its own JDK"

That's by design — Android Studio includes a bundled "JBR" (JetBrains Runtime).
Tateru auto-detects it at `<Android Studio install>/jbr/bin/java`. So even
after Phase 4, once Android Studio is installed, Java is "back" from Tateru's
perspective. This is expected and fine.

## "Reset broke my OTHER Flutter / Android projects"

The Phase 2 / Phase 3 wipes are global — they remove the SDK from the
entire OS, not just from Tateru. If you have other Flutter or Android
projects, you need to reinstall the SDK (manually or via Tateru's
`✨ Install Flutter for me` button) before they'll work again.

## More help

- In-app: **Support → User Manuals → Troubleshooting** (or open
  [Troubleshooting](TROUBLESHOOTING.md))
- Ask Bob: **Sidebar → Ask Bob** — type your question, gets a 2-5 sentence
  answer from Tateru's knowledge base
- Email: support@tateru.app

---

# Safety notes

- **Never run these scripts on a machine you don't own.** They're destructive.
- **The `sudo rm -rf` calls in the macOS + Linux sections are NOT reversible.** Double-check the paths before pasting.
- **Tateru's data lives in userData** (`$APPDATA\tateru-pro-plus` on Windows, etc.). Phase 1 wipes it. If you have unfinished projects there, **export them first** via My Apps → Export, OR back up the entire userData dir before continuing.
- **Windows registry / OS-level state is not touched** by these scripts. They only operate on the user's filesystem + environment variables. No reboot loops, no driver mess.
