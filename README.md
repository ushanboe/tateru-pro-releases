# Tateru Pro — Public Release Binaries

This repository hosts the **public release binaries** for Tateru Pro, an AI-driven Android app pipeline (with experimental macOS + iOS app builds). The product source code lives in a separate private repository.

- **Product website:** https://tateru.app
- **Quick Start guide:** https://tateru.app/quick-start
- **Beta access:** https://tateru.app/beta
- **Support:** support@tateru.app

---

## Install with one line

Pick your OS and copy/paste into a terminal:

### Linux + macOS

```bash
curl -fsSL https://tateru.app/install | bash
```

### Windows (PowerShell — right-click Start → "Terminal" or "Windows PowerShell")

```powershell
irm https://tateru.app/install.ps1 | iex
```

That's it — the installer fetches the latest version, drops it in the right place for your OS, and launches it. **Make sure you've installed the prerequisites first** (see below). For manual install (or to review the install script before running it), see [INSTALL.md](INSTALL.md).

### A note on first-launch warnings

Tateru is **unsigned during beta**. Your OS will show a one-time security warning on first launch — click through it (the installer prints the exact steps). This goes away in 1.0 when we add code-signing certificates.

---

## Uninstall with one line

Same pattern. **`bash <(...)`** is required (process substitution) so the interactive "keep my projects?" prompt works — don't use `curl | bash` for uninstall.

### Linux

```bash
bash <(curl -fsSL https://tateru.app/uninstall-linux.sh)
```

### macOS

```bash
bash <(curl -fsSL https://tateru.app/uninstall-macos.sh)
```

### Windows

Open **Settings → Apps → Installed apps** → find **Tateru Pro** → click **⋯** → **Uninstall**.

Each uninstaller asks whether to keep your data (projects, built APKs, login) or wipe everything. Default is **keep** — a future reinstall picks up where you left off.

---

## ⚠ Install these BEFORE running the one-liner (required prerequisites)

**The #1 reason fresh installs get stuck is missing or wrong-version dependencies.** Tateru's setup wizard checks for these on launch and refuses to build if any are missing. Install + verify each one **before** running the installer:

| Required | Version | Install from |
|---|---|---|
| **Flutter SDK** | **3.41.9** (NOT 3.44.0 — known `flutter create` bug) | https://docs.flutter.dev/get-started/install |
| **Android Studio** | Latest stable — **open it once after install** to download the SDK (~3 GB) | https://developer.android.com/studio |
| **Java JDK** | Temurin 17 LTS (or accept Android Studio's bundled JBR) | https://adoptium.net/temurin/releases/ |
| **Git** | Latest | https://git-scm.com/downloads |
| **Node.js + npm** | LTS (18 or newer) — required for GreenThumb (marketing website + docs) | https://nodejs.org/en/download |
| **Windows only: Developer Mode** | Must be **ON** — Flutter needs it for symlink support, or APK builds fail | Settings → Privacy & security → For developers → **Developer Mode = On** |

**Notes:**

- **Flutter must be 3.41.9** — 3.44.0 has a `flutter create` bug that crashes the first APK build. Pin to 3.41.9.
- **Open Android Studio once** after installing — the IDE is just the shell; the first-launch wizard downloads the actual SDK. Skip this and detection fails.
- **Java is optional if you installed Android Studio** — Tateru auto-detects its bundled JBR. Install Temurin standalone only if you skipped Android Studio.
- **Node.js is only for GreenThumb** — the marketing-website/docs generator runs `npm install` + a Next.js preview. The app build itself does NOT need Node. Install it before using GreenThumb.
- **Windows Developer Mode is required to build** — a fresh Windows install shows a symlink-permission warning on the first build until Developer Mode is on. This is a Flutter requirement, not a Tateru one.

Full per-OS uninstall + clean-reinstall recipes for every dependency: see [docs/RESET_AND_REINSTALL.md](https://github.com/ushanboe/tateru-pro-releases/blob/main/docs/RESET_AND_REINSTALL.md).

---

## Where your data lives

Tateru stores all user data — login, license, generated projects, built APKs, SQLite DB — **outside** the app bundle, so reinstalls and updates never touch your work.

| OS | Data dir |
|---|---|
| Linux | `~/.config/tateru-pro-plus/data/` |
| macOS | `~/Library/Application Support/tateru-pro-plus/data/` |
| Windows | `%APPDATA%\tateru-pro-plus\data\` |

LLM API keys are stored separately in your OS keychain (macOS Keychain / GNOME Keyring / Windows Credential Manager). The one-liner uninstallers do NOT touch the keychain by design — open Keychain Access / Credential Manager / Seahorse to remove them manually.

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

## Advanced install / uninstall paths

The one-liner above covers ~95% of users. If you want to:

- **Review the install script before running it** (security-conscious users)
- **Install a specific version** instead of latest (testing, rollback)
- **Use the `.deb` package** on Linux instead of the AppImage (apt-managed updates)
- **Install via portable `.zip`** on Windows instead of the NSIS installer (no admin, side-by-side versions)
- **Download via browser** and install by hand (no terminal)
- **Verify SHA256 checksums** before installing
- **Factory-reset your install** with explicit per-OS commands

→ See [**INSTALL.md**](INSTALL.md) for the comprehensive guide.

For the deepest macOS-specific details (fast-reset cycle for testing, Console crash report path, etc.), see [MACOS_INSTALL.md](MACOS_INSTALL.md).

---

## License + privacy

The Tateru Pro app is proprietary software. By downloading and installing, you agree to the [Terms of Use](https://tateru.app/terms) and [Privacy Policy](https://tateru.app/privacy).
