# Tateru Pro — macOS Install Guide

**App:** Tateru Pro
**Version:** v1.0.0-beta.8.2+ (Prisma multi-platform engine fix; first stable Mac build)
**Platform:** macOS 11+ (Big Sur or newer), x64 (Apple Silicon runs via Rosetta 2)
**Build status:** Unsigned (no Apple Developer signature) — Gatekeeper warning expected on first launch
**Owner:** KangaBlue.au
**Contact:** support@tateru.app
**Last updated:** 2026-04-26

---

## TL;DR

```bash
# Download + extract + install
gh release download v1.0.0-beta.8.2 --repo ushanboe/tateruProPlus --pattern "*-mac.zip"
unzip -q "Tateru.Pro-1.0.0-beta.8.2-mac.zip"
mv "Tateru Pro.app" /Applications/
xattr -dr com.apple.quarantine "/Applications/Tateru Pro.app"

# First launch — right-click → Open (Gatekeeper bypass)
open "/Applications/Tateru Pro.app"
```

---

## 1. Uninstall a previous version (skip if first install)

If you already have a Tateru Pro on this Mac and want to start clean:

### GUI option (no Terminal needed)

1. **Quit the app** if it's running — Cmd+Q while it's focused, or right-click the Dock icon → Quit
2. Open **Finder** → click **Applications** in the sidebar
3. Find **Tateru Pro**
4. **Right-click** → **Move to Trash** (or drag to the Trash icon in the Dock)
5. Empty Trash if you want

This removes the .app bundle only — your data + login persist (intentional, so you can update without losing your projects). For a true factory reset, also run steps 3 + 4 from the Terminal option below.

### Terminal option (full control)

```bash
# 1. Quit the app if it's running
osascript -e 'quit app "Tateru Pro"' 2>/dev/null

# 2. Delete the .app bundle
rm -rf "/Applications/Tateru Pro.app"

# 3. (Optional but recommended for clean test) Wipe app data
rm -rf ~/Library/Application\ Support/Tateru\ Pro
rm -rf ~/Library/Caches/com.tateru.pro.plus
rm -rf ~/Library/Preferences/com.tateru.pro.plus.plist
rm -rf ~/Library/Logs/Tateru\ Pro

# 4. Wipe Tateru Cloud auth + cache (your JWT, prompt cache, offline queue)
rm -rf ~/.tateru-pro
```

> All these commands are **macOS-native** (`osascript`, `xattr`, `/Applications/`). They run in macOS Terminal.app — open with Spotlight (Cmd+Space) → type "Terminal" → Enter. They are NOT Linux commands; don't run them on a Linux dev machine.

**What each step removes:**

| Step | Removes | Effect on next launch |
|---|---|---|
| 2 | `.app` bundle only | Reinstall lands "logged in" via cached JWT (steps 3-4 untouched) |
| 3 | macOS application support data, caches, prefs | Window position + UI prefs reset |
| 4 | Cloud auth token + offline queue | Forced re-login; offline-queued analytics lost |

For a true factory-reset, run all 4 steps. For "just update the app", step 2 only.

---

## 2. Download v1.0.0-beta.8.2

### Option A — `gh` CLI (recommended)

```bash
# Authenticate once (skip if you've used gh before)
gh auth login --git-protocol https --hostname github.com

cd ~/Downloads
gh release download v1.0.0-beta.8.2 \
  --repo ushanboe/tateruProPlus \
  --pattern "*-mac.zip"
```

### Option B — Browser download

1. Open <https://github.com/ushanboe/tateruProPlus/releases/tag/v1.0.0-beta.8.2>
2. Sign in to GitHub (the repo is private — your beta-tester invite gives access)
3. Click `Tateru.Pro-1.0.0-beta.8.2-mac.zip` to download

### (Optional) Verify checksum

```bash
gh release download v1.0.0-beta.8.2 \
  --repo ushanboe/tateruProPlus \
  --pattern "SHA256SUMS-beta.8.2"

shasum -a 256 -c SHA256SUMS-beta.8.2 2>/dev/null | grep -i mac
# Should output: Tateru Pro-1.0.0-beta.8.1-mac.zip: OK
```

If the checksum doesn't match, re-download. Don't install a corrupted artifact.

---

## 3. Install

```bash
cd ~/Downloads

# Extract the zip — produces "Tateru Pro.app"
unzip -q "Tateru.Pro-1.0.0-beta.8.2-mac.zip"

# Move to Applications
mv "Tateru Pro.app" /Applications/

# Clear macOS quarantine flag so right-click → Open works smoothly
xattr -dr com.apple.quarantine "/Applications/Tateru Pro.app"
```

**About the quarantine flag:** macOS automatically tags any file downloaded from the internet with `com.apple.quarantine`, which makes Gatekeeper extra-paranoid. Removing it preemptively skips one warning layer — without removing it, Gatekeeper will refuse Open even after a right-click.

---

## 4. First launch — Gatekeeper bypass

Because this build is **unsigned** (no Apple Developer Certificate), macOS will refuse to open it on a normal double-click:

> **"Tateru Pro" cannot be opened because Apple cannot check it for malicious software.**
> *This software needs to be updated. Contact the developer for more information.*

This is **expected** and **safe** — closed-beta builds aren't worth $99/year + 6 hours of cert ceremony for. Two ways to bypass:

### Option 1 — Right-click bypass (works on all macOS versions)

1. Open Finder → `/Applications`
2. **Right-click** (or **Control-click**) the `Tateru Pro.app` icon
3. Click **Open** in the menu
4. A new dialog says *"macOS cannot verify the developer..."* — click **Open** again
5. App launches normally
6. **Subsequent launches** work via double-click — macOS remembers the allowlist

### Option 2 — System Settings bypass (macOS 13 Ventura+)

1. Try to double-click the app (gets blocked with the warning)
2. Open **System Settings** → **Privacy & Security**
3. Scroll down — you'll see *"Tateru Pro" was blocked from opening because it is not from an identified developer.*
4. Click **Open Anyway**
5. Confirm in the dialog → app launches
6. Subsequent launches work via double-click

After either option **once**, the app is permanently allowlisted on this Mac.

---

## 5. Verify the install worked

After first launch, you should see:

1. **SetupWizard** appears (if it's a fresh install) — work through Flutter / Android / Java / LLM key checks
2. Sign in with your test account at the login page
3. **Settings → Cloud Account** — shows your email + tier
4. **Settings → Upgrade Plan** — opens a modal with three buttons:
   - Maker — $39/mo
   - Pro Monthly — $79/mo
   - **Pro Annual — $63/mo billed annually** (purple gradient + "SAVE 20%" badge + "Private Build Mode (no telemetry)" subtitle)
5. **Register page** — has an explicit checkbox: *"I have read and agree to the Terms of Service and Privacy Policy (version 2026-04-26)..."* (required to submit)

If you see all of those → the Phase 17 features (mods 9.88, 9.89, 9.90, 9.91) are running correctly.

---

## 6. Reset / re-test cycle (fast)

If you're going to install + uninstall multiple times for testing:

```bash
# Tear down (preserves Keychain LLM keys; wipes app state + auth)
osascript -e 'quit app "Tateru Pro"'
rm -rf "/Applications/Tateru Pro.app" ~/.tateru-pro

# Re-install (from a saved zip)
cd ~/Downloads
unzip -q "Tateru.Pro-1.0.0-beta.8.2-mac.zip"
mv "Tateru Pro.app" /Applications/
xattr -dr com.apple.quarantine "/Applications/Tateru Pro.app"
open "/Applications/Tateru Pro.app"
```

About 30-second round-trip.

---

## 7. What's NOT touched by uninstall

These persist regardless of what uninstall path you take. Useful to know — and to clean separately if you want a true bare-machine state.

| Location | What it holds | Why it's not in uninstall |
|---|---|---|
| **macOS Keychain** entries (`Tateru Pro`, `Anthropic API Key`, etc.) | Your LLM provider API keys | Removing forces you to re-enter them on every reinstall — too painful for active testing |
| `~/AppForgeProjects/` (or wherever you set Settings → Paths) | Your generated projects (specs, source code, APKs) | Your work — only you should decide if it goes |
| Output APKs in `output_apps/` (if configured to a custom dir) | Built APK artifacts | Same as above |

To wipe Keychain entries manually:
1. Open **Keychain Access.app**
2. Search `tateru` or `anthropic`
3. Delete the matching items

---

## 8. Known limitations of this Mac build

| Limitation | Workaround |
|---|---|
| **Unsigned** — Gatekeeper warns on first launch | Right-click → Open (one-time) |
| **x64 only** — Apple Silicon runs via Rosetta 2 | Apple's Rosetta translation works fine; slight startup delay first time. Native arm64 build coming in a future beta. |
| **ZIP not DMG** — slightly less polished install UX | The zip-extract-then-drag pattern works on every macOS; nothing else needed |
| **No notarization** — unlikely but possible future macOS Gatekeeper updates may flag it | Notarized builds will arrive when proper Apple Developer signing is in place |
| **Built on Linux (cross-compile)** — first Mac build, untested on actual Apple hardware | Report any Mac-specific issues to support@tateru.app — first-tester pain is expected |

---

## 9. Reporting issues

| Issue type | Where |
|---|---|
| Install fails (download, unzip, move) | <support@tateru.app> + paste terminal output |
| App won't launch (silently quits, crashes on start) | <support@tateru.app> + Console.app crash report (Applications → Utilities → Console.app → Crash Reports → "Tateru Pro") |
| App launches but a Mac-specific feature is broken | <support@tateru.app> + screen recording if visual |
| Anything else | GitHub Issues at <https://github.com/ushanboe/tateruProPlus/issues> |

When reporting include:
- macOS version (`sw_vers -productVersion`)
- Apple Silicon vs Intel (`uname -m` — `arm64` vs `x86_64`)
- Tateru Pro version (Settings → bottom of the page)
- Steps to reproduce
- Console log if available

---

## Document history

| Version | Date | Change |
|---|---|---|
| 1.0 | 2026-04-26 | Initial draft for v1.0.0-beta.8 (first macOS build). Covers install, uninstall, Gatekeeper bypass, reset cycle, known limitations. |
| 1.1 | 2026-04-27 | Bumped to v1.0.0-beta.8.2 after Prisma multi-platform engine fix. Added GUI uninstall option + clarified macOS-native command provenance for cross-platform readers. |
