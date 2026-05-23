---
**App:** Tateru Pro
**Version:** 1.0.0-beta.9.32.13
**Owner:** KangaBlue.au
**Contact:** support@tateru.app
**Last updated:** 2026-05-11
---

# Troubleshooting

User-friendly recipes for the most common things that go wrong, organized by symptom. Bob (sidebar → Ask Bob) has read this guide and can answer specific questions — try Bob first if your symptom doesn't exactly match anything below.

## Table of contents

1. [Install + first launch](#install--first-launch)
2. [Setup Wizard issues](#setup-wizard-issues)
3. [Build pipeline issues](#build-pipeline-issues)
4. [APK build (Gradle) issues](#apk-build-gradle-issues)
5. [Send to Phone (Android)](#send-to-phone-android)
6. [iOS issues (Mac)](#ios-issues-mac)
7. [GreenThumb (audit + website)](#greenthumb-audit--website)
8. [Cloud Sauce indicator (sidebar pill)](#cloud-sauce-indicator-sidebar-pill)
9. [Send Feedback / Ask Bob](#send-feedback--ask-bob)
10. [Login / billing / subscription](#login--billing--subscription)
11. [Performance + disk space](#performance--disk-space)
12. [Specific error messages — alphabetical lookup](#specific-error-messages--alphabetical-lookup)
13. [Still stuck?](#still-stuck)

---

## Install + first launch

### "Windows protected your PC" warning on Windows install

Tateru isn't code-signed yet (we'll sign in a future release; cert costs $300-500/yr and we're holding until post-beta). On first launch:

1. Click **More info**
2. Click **Run anyway**
3. Future launches don't show the warning

### "Tateru Pro can't be opened" on macOS

Same root cause as Windows — not code-signed yet.

**Easy fix:** Right-click `Tateru Pro.app` in Finder → **Open** → **Open** in the dialog.

**Once-and-done fix:** Terminal → `xattr -d com.apple.quarantine "/Applications/Tateru Pro.app"`.

### "There's no app icon to launch on Windows"

You installed via the .zip instead of the NSIS installer.

**Fix:** Re-install using `Tateru.Pro-Setup-<version>.exe` (the installer). It creates Start Menu + Desktop shortcuts + Add/Remove Programs entry.

The .zip is power-user mode; you have to find + double-click `Tateru Pro.exe` manually each time.

### Windows install takes "About 1 hour" to extract the zip

Pre-9.32.13 only. Mod 10.119 (9.32.13+) packed the 391-file reference library inside the asar archive — install is now ~30 seconds. Upgrade to 9.32.13+ to fix.

Workaround if stuck on older versions: use 7-Zip instead of Windows Explorer's native unzip (3-5x faster on many-small-files archives).

### Tateru opens to a blank window

Most common cause: the API server crashed during startup. Mac + Windows users were affected by mod 9.94 (Prisma engines) and mod 9.95 (sharp binaries) and mod 10.07 (Prisma client collision) at various points. All three are fixed in 9.32.13+.

If you see this on 9.32.13+:

1. Check the underlying terminal (if you launched from a terminal) — there will be an error message
2. Open a new terminal:
   - **Linux:** `cat /tmp/tateru-pro-*.log` (Tateru writes startup logs there)
   - **Mac:** Console.app → search "Tateru" → check for crash logs
   - **Windows:** Event Viewer → Windows Logs → Application → look for Tateru Pro entries
3. Send the error to support@tateru.app via Sidebar → Send Feedback (which works even when the main window is blank — opens to a separate Electron window)

---

## Setup Wizard issues

### Flutter not detected

Either you haven't installed Flutter, or it's in a non-standard location.

**Fix:**

1. If not installed: install Flutter from [flutter.dev/docs/get-started/install](https://flutter.dev/docs/get-started/install) → restart Tateru
2. If installed in a non-standard location: paste the full path to the Flutter binary into the Override field
   - Linux/Mac: `/path/to/flutter/bin/flutter`
   - Windows: `C:\path\to\flutter\bin\flutter.bat`

Click **Save & Re-detect**.

### "Flutter detected but Android SDK not found"

Even though Flutter ships with some Android tooling, you still need a full Android SDK install (Android Studio includes it, or install standalone).

**Easiest path:** install Android Studio from [developer.android.com/studio](https://developer.android.com/studio). It bundles the Android SDK + Java JDK + emulator. Tateru auto-detects all three after install.

### Java not detected even though Android Studio is installed

Tateru looks for Java in 5 places: Android Studio's bundled JBR, IntelliJ's bundled JBR, JetBrains Toolbox's bundled JBR, standalone Adoptium / Oracle / Microsoft / Zulu / Amazon Corretto installs, and `JAVA_HOME` env var.

If detection fails on a fresh install, your Android Studio JBR path may be non-standard. Find it:

```bash
# Linux
find /opt /usr -name jbr -type d 2>/dev/null

# Mac
find /Applications -name jbr -type d 2>/dev/null

# Windows (PowerShell)
Get-ChildItem -Path "C:\Program Files\Android", "$env:USERPROFILE\AppData\Local" -Recurse -Filter jbr -Directory -ErrorAction SilentlyContinue
```

Paste the result into the Java Override field → Save & Re-detect.

### "API key test failed" on a fresh key

A few common causes:

- **Wrong format** — Anthropic keys start with `sk-ant-`, OpenAI with `sk-`, DeepSeek with `sk-`. If yours doesn't match, you copied the wrong thing.
- **Whitespace** — leading/trailing spaces breaks parsing. Re-copy without selecting whitespace.
- **Provider account not activated** — some providers (Anthropic, OpenAI) require billing setup before API keys work. Add a payment method in the provider dashboard, then re-test.
- **Rate-limited** — first request after a key creation can be 429. Wait 30 seconds, retry.

---

## Build pipeline issues

### Pipeline stuck on a phase

The Pipeline page shows a yellow / spinning icon for the current phase. If it doesn't progress for 15+ minutes:

1. Check the Live Console at the bottom of the page — usually there's an error there
2. Click **Cancel Build** (top-right) → returns the project to TEMPLATE → click **Start Pipeline** to retry from scratch
3. If the same phase keeps hanging: try switching that agent's model in Settings → Build Model Config → Customize per agent. E.g. if Doc-Tor hangs on Haiku, switch to Sonnet.

### "BUILD_ERROR" or red ✗ on a phase

Click the phase tile → see the error in the Logs panel.

Common errors + fixes:

| Error | Cause | Fix |
|---|---|---|
| `Failed to parse Doc-Tor JSON` | LLM emitted malformed JSON | Mod 10.115 (9.32.13+) state-machine repair handles most cases. If you're on an older version, switch Doc-Tor to Sonnet 4.6 (Haiku is more prone to malformed JSON on long output). |
| `Failed to parse DocSmith JSON` | Same root cause as above, in DocSmith | Mod 10.131 (9.32.13+) ports the same fix to DocSmith. Upgrade. |
| `flutter create` warnings: `Expected ':' on line 6 column 1` | Bob emitted Dart `//` comments at the top of pubspec.yaml (invalid YAML) | Mod 10.130 (9.32.13+) defensive strip removes these. Upgrade. Or manually edit pubspec.yaml to remove leading `//` lines. |
| `agent-orange failed: ENOENT: ... proguard-rules.pro` | The Android scaffold wasn't created (typically caused by the pubspec issue above) | Same fix — mod 10.130 handles this cascade. |

### Agent Orange runs many cycles without converging

Agent Orange runs up to 7 review cycles. Most builds clear in 1-3. Music apps + AI-feature-heavy apps sometimes need 5+. If 7 cycles exhaust without clearing, the pipeline marks status FAILED.

**Options:**

1. Click **Diagnose** on the failed build — Tateru's bug library may have a match
2. Click **Refine** with a custom instruction — sometimes one targeted hint is faster than 7 cycles of incremental fixes
3. Try **Restart Pipeline** after switching Agent Orange to Opus (more nuanced fixes per cycle)

### "No Apple Developer Team is set" — but I set it in Xcode

Pre-9.32.x bug — `flutter create --platforms=ios` was wiping the Team setting on every iOS build. **Mod 10.75 (9.32.x+) preserves it.** Upgrade.

If you're on 9.32.x+ and still seeing this:

1. The error message includes the absolute path to `project.pbxproj` — open that file in a text editor
2. Search for `DEVELOPMENT_TEAM` — there should be 2-3 entries (one per build configuration) all set to your team ID
3. If they're empty: open `Runner.xcworkspace` in Xcode → Runner target → Signing & Capabilities → re-set the team → save

---

## APK build (Gradle) issues

### `cannot find symbol: class Registrar`

Old `file_picker` package using v1 Flutter embedding. Bob's SAFE_VERSIONS pins this to `^8.1.7` but earlier mods (pre-10.105) had bypass bugs. **Mod 10.120 (9.32.12+) extracted SAFE_VERSIONS to a shared helper called from all 4 pubspec writers** — fixed.

If you see this on 9.32.12+:

1. Open `pubspec.yaml` in your project
2. Confirm `file_picker: ^8.1.7` (not `5.x`, `6.x`, or `^11.x`)
3. Confirm `dependency_overrides:` block contains `file_picker: ^8.1.7`
4. If both look right, run `flutter clean && flutter pub get` then **Rebuild APK**

### `Could not find package just_audio_equalizer`

LLM hallucinated a package name that doesn't exist on pub.dev. Bob is supposed to verify all package names but occasionally misses.

**Fix via Refinement:**

> Remove just_audio_equalizer from pubspec.yaml — the package doesn't exist on pub.dev. If equalizer functionality is needed, use just_audio's built-in audio effects instead.

Click Refine → Rebuild APK.

### `error: cannot find symbol class Registrar` (record_linux)

`record 5.x` pulls in `record_linux 0.7.2` which is incompatible with newer `record_platform_interface`. Bob's SAFE_VERSIONS pins to `^6.x` (mod 9.96).

**Fix:**

1. Edit pubspec.yaml: `record: ^6.2.0` + `record_linux: ^1.3.0` in dependencies
2. Confirm dependency_overrides: section has `record: ^6.2.0`
3. `flutter clean && flutter pub get` → Rebuild APK

### "Missing classes detected while running R8"

R8 (Android shrinker) flagged classes from MediaPipe / OkHttp TLS providers / AutoValue annotation processors. Bob's `patchProguard` step writes `-dontwarn` rules for the common cases (mod 9.97 / 10.63).

If you still hit this:

1. Open `android/app/proguard-rules.pro`
2. Add `-dontwarn <package.name>.**` for each missing class
3. Rebuild APK

Or via Refinement:

> Add `-dontwarn` rules to android/app/proguard-rules.pro for the missing classes flagged in the R8 error: <paste the error here>

### "Build failed with exit code 1" but the APK is on disk

Mod 10.69 (9.32.x+) handles this — Gradle sometimes exits non-zero AFTER successfully producing the APK (post-build plugin lifecycle hooks fail without affecting the artifact). Tateru now checks for the APK file existence as the source of truth, not the exit code.

If you're on 9.32.x+ and seeing "Auto-build failed" over a working APK, file a bug — should be fixed.

### Disk full mid-build

Symptoms: confusing compile errors, half-generated files, EBADF / ENOSPC in logs.

**Fix:**

1. Free disk space
2. Settings → System Info → Refresh — confirm you have >5GB free
3. **Restart Pipeline** on the failed project (don't just Rebuild APK — the project source may be partially written)

To prevent: keep an eye on the disk-space warning in the Spec Approval Panel before approving builds (mod 10.121).

---

## Send to Phone (Android)

### "spawn adb ENOENT" when trying to install

Tateru can't find ADB. Pre-mod-10.123 versions only looked for bare `adb` (Linux/Mac binary name) — Windows ships `adb.exe`. **Mod 10.123 (9.32.13+) adds the .exe suffix on Windows + expanded candidate paths.**

If you're on 9.32.13+ and still seeing this:

1. Add Android SDK platform-tools to your PATH:
   - **Windows:** `%LOCALAPPDATA%\Android\Sdk\platform-tools` (Win+R → sysdm.cpl → Advanced → Environment Variables → Path → Edit → New)
   - **Mac:** `~/Library/Android/sdk/platform-tools`
   - **Linux:** `~/Android/Sdk/platform-tools`
2. Restart Tateru (PATH is read at startup)

### Wireless ADB pair fails with "no devices"

**First check you're in the right place.** The Wireless ADB pair UI lives in **Code Workbench → Deploy tab → Wireless mode** (NOT in Settings, NOT on the Pipeline page directly). Open your project → Pipeline → click **Open Workbench** → Deploy tab → make sure Wireless is selected (USB Cable is the alternative toggle).

Then common causes:

- **Wrong port** — pairing port and connect port are DIFFERENT (the phone displays both, easy to mix up). Check your phone screen carefully.
- **Pairing code expired** — codes auto-expire after ~60 seconds. Get a fresh one from your phone.
- **Different networks** — phone and PC must be on the same Wi-Fi network. VPN on either side may cause issues too.

### "Stuck 5 times" pairing on Windows

Mod 10.04 / 10.123 / 10.124 fixed several Windows-only ADB issues. Upgrade to 9.32.13+.

If still failing on 9.32.13+:

1. Verify ADB works manually: `adb devices` in PowerShell — you should see your paired phone listed
2. If `adb` itself isn't found, see "spawn adb ENOENT" above
3. If `adb` works but Tateru fails, file a bug with logs from Settings → Diagnostics → Download Support Logs

---

## iOS issues (Mac)

### iPhone doesn't appear in the device dropdown

Mod 10.38c added the **iOS Connection Diagnostic modal** — click the 🩺 stethoscope button next to the device dropdown. The modal runs all 3 detection sources (`xcrun simctl list devices`, `flutter devices --machine`, `xcrun xctrace list devices`) and shows raw output.

Common fixes:

- Phone not trusted: unplug, replug, accept the "Trust This Computer?" prompt
- Xcode CLI tools missing: `xcode-select --install` in Terminal
- macOS hasn't recognized the device: open Finder → check the sidebar for the iPhone (system-level recognition)

### "CocoaPods not installed" but I just installed it

Mod 10.28 bumped the `pod --version` timeout from 10s to 90s. First invocation after `brew install cocoapods` clones the specs repo (~30-60s) and was firing a misleading "not on PATH" timeout pre-mod-10.28.

If you're on 9.32.x+ and still seeing this: `pod --version` in your Terminal manually — wait for it to complete. Then go back to Tateru and click **Re-detect All** in Settings → SDK Paths.

### macOS .app builds but app errors at startup trying to download Gemma

Bob's Android-spec output uses `flutter_gemma` for on-device LLM. The Mac plugin doesn't ship the same way as the Android plugin — Mac runtime tries to download a model that doesn't exist for the Mac platform.

This is a known limitation — Bob isn't yet platform-aware enough to swap on-device LLM for cloud BYOK API on Mac builds. Workaround: use **Refinement** with:

> When running on macOS, replace flutter_gemma calls with cloud Anthropic API calls using the user's saved ANTHROPIC_API_KEY.

---

## GreenThumb (audit + website)

### Audit reports all 4 docs as missing even though they exist

Pre-mod-10.126: audit was reading from a stale save-local snapshot, not from the live project dir.

**Fix in mod 10.126 (9.32.13+):** audit always reads from `~/.tateru-pro/data/projects/<slug>/` first. Upgrade.

### Privacy reports correct email; Terms reports wrong email

DocSmith generated Terms with a placeholder email instead of the user's real email. **Mod 10.127 (9.32.13+) tightened DocSmith's prompt to forbid 12 named placeholder patterns** + adds diagnostic logging showing the actual email found in each doc.

For older builds: open `TERMS_OF_USE.md` in your project, search for placeholder emails (`contact@example.com`, `your@email.com`, `[Your Email]`, etc.), replace with your real email, save, re-run audit.

### Generate Website fails with "rsync is not recognized" on Windows

The website-regenerate flow uses Unix shell commands in 3 paths (rsync, cp, pgrep). Mod 10.125 fixed the 6 `rm -rf` calls; the rsync/cp/pgrep are tracked as 10.125b for the next release.

Workaround: regenerate website on a Linux/Mac machine. Or wait for 10.125b to ship.

### Download zip button doesn't trigger a download in Electron

Mod 10.86 (9.32.x+) fixed this via fetch+blob+ObjectURL pattern + Electron `will-download` handler. Upgrade.

If on 9.32.x+ and still no download: check your browser's downloads folder — the file might be downloading silently. Mod 10.87 added explicit "✓ Saved (NN KB)" visible feedback.

---

## Cloud Sauce indicator (sidebar pill)

The small LED-style pill below the app version in the sidebar shows whether the **latest** authoritative build rules (`MISTAKES.md` + `CURATED_PACKAGES.md`) from Tateru's cloud vault are in use. **Hidden by default** — only appears when you've opted into the `CLOUD_RULES` flag.

See [Settings → Cloud Sauce indicator](SETTINGS_REFERENCE.md#cloud-sauce-indicator) for full state table + enable instructions. Common issues below.

### Pill doesn't appear in the sidebar

Expected — it's off by default. To enable, add `CLOUD_RULES=1` to your user data .env:

- **Linux:** `~/.config/tateru-pro-plus/.env`
- **macOS:** `~/Library/Application Support/tateru-pro-plus/.env`
- **Windows:** `%APPDATA%/tateru-pro-plus/.env`

Restart Tateru after editing.

### Pill stays on 🔵 "offline" after clicking Pull (cache populated, but never reaches 🟢 "latest")

This is the most common state for dogfood installs as of the most recent dev tree. The cache pulled successfully (you'd see 🟡 **not downloaded** if it had failed) — Bob IS loading your freshly-pulled rules. The pill just can't verify "latest" because the cloud's cheap version-check endpoint (`GET /api/v1/rules/version`) isn't reachable from your install.

**Why:** As of 2026-05-23 the new `/version` endpoint hasn't been deployed to Railway yet. Once it ships, the pill will flip to 🟢 **latest** on the next window-focus check (within 60 seconds).

**Workaround:** none needed — the rules are working. The pill is being honest about not being able to confirm "latest" without verification. This is the **no-false-positive design** — we'd rather show 🔵 offline than mislead you into thinking you're current when we don't actually know.

### 🟡 "not downloaded" — Pull button does nothing / spins forever

Pull requires a valid Tateru license JWT (same auth as logging in). If pull fails silently:

1. Open Settings → Account. Confirm tier shows ACTIVE (not EXPIRED / CANCELLED).
2. Click Refresh in the Account panel. Try Pull again.
3. If still failing, sign out + sign back in. License JWT will refresh.
4. If you're behind a corporate proxy / firewall blocking `api.tateru.app`, the pull will fail until the network is reachable.

### Pill shows 🟠 "update available" even though I just pulled

This means another newer rule version was published between your pull and the next version-check (window focus or 60s tick). Click **Pull** again — pill will flip to 🟢 **latest**.

If it keeps reverting to 🟠 immediately after every pull, that's a bug — please send feedback (sidebar → Send Feedback) with your cached version (`~/.tateru-pro/data/cloud-cache/rules.version.json`).

### I want to revert to bundled rules

Set `CLOUD_RULES=0` (or delete the line) in your user data .env. Restart Tateru. The pill disappears and Bob falls back to the bundled `MISTAKES.md` + `CURATED_PACKAGES.md` that shipped with this Tateru version. The cache on disk is harmless and can be ignored or deleted.

### Cache seems corrupted — delete and re-pull

Delete the `cloud-cache/` directory inside your user data dir:

```bash
# Linux
rm -rf ~/.tateru-pro/data/cloud-cache/
# macOS
rm -rf "$HOME/Library/Application Support/tateru-pro-plus/data/cloud-cache/"
# Windows (PowerShell)
Remove-Item -Recurse -Force "$env:APPDATA\tateru-pro-plus\data\cloud-cache"
```

Restart Tateru. Pill returns to 🟡 **not downloaded**. Click Pull to repopulate.

---

## Send Feedback / Ask Bob

### "Feedback form not configured yet" warning

The build wasn't packaged with `VITE_FORMSPREE_FEEDBACK_ID`. This was a Phase 27 fix — every release post-9.32 has the ID baked in. Upgrade.

If you really can't upgrade, email `support@tateru.app` directly — same destination as Send Feedback.

### "Send Feedback succeeded but I never got a reply"

We reply within 24 hours during beta. Check:

- Your spam folder
- That the contact email field on the feedback form was correct (defaults to your registered email; check Settings → Account)

If still no reply after 48 hours, email `support@tateru.app` directly with your original feedback content + ask for status.

### Ask Bob says "I don't know"

Bob is trained on Tateru's public docs (this guide, the user manual, settings reference, build mode guide, etc.) + recent release notes. If your question is outside that scope, Bob honestly says so and suggests Send Feedback.

Specifically, Bob can answer:

- How Tateru itself works (any UI element, any feature, any setting)
- What's in any recent release
- Common troubleshooting recipes
- Pricing + plans

Bob CANNOT answer:

- Coding questions about your specific app's source (try the in-app code Workbench AI Chat for that)
- Questions about competitor products
- Questions about general Flutter / Dart / iOS / Android development outside of Tateru's context

---

## Login / billing / subscription

### "Cannot connect to cloud" on login

Cloud is at `https://api.tateru.app`. Test it manually:

```bash
curl -s https://api.tateru.app/api/v1/legal/current
```

If that returns JSON, cloud is up — issue is local. Check:

- Your firewall isn't blocking outbound HTTPS to api.tateru.app
- Your VPN/proxy isn't intercepting
- Your DNS resolves api.tateru.app

If `curl` fails, cloud is genuinely down — try again in 5-10 minutes. If still down, file a bug to support@tateru.app from a different machine.

### "GitHub push fails with cryptic git usage message"

Pre-mod-10.124: PATs containing `&`, `|`, `>`, `<`, `^`, `%` (Windows shell metacharacters) broke the git command on Windows because the URL was passed via `cmd.exe` which interprets those chars.

**Fix in mod 10.124 (9.32.13+):** uses `spawn` with arg array, no shell parsing. Upgrade.

Workaround on older versions: regenerate your PAT until you get one without shell-meta chars. Or push from cmd.exe with the URL quoted.

### "My tier shows wrong after upgrading"

Settings → Account → click **Refresh**. Or sign out + sign back in. Cloud auth refreshes auth-on-window-focus + on a 30s throttle, so usually picks up automatically within 30s of the upgrade.

If still wrong after sign out + sign in, contact support — could be a Stripe webhook delivery issue.

### "Subscription expired but I want my data"

Your data is local — stays on your machine forever even after subscription ends. Sign in, use Settings + browse My Apps + export projects. Only the build pipeline is gated.

To resume building: Settings → Upgrade Plan → pick a tier → resubscribe.

---

## Performance + disk space

### Tateru is slow / using lots of RAM

Check Dashboard → System Health (top-right). Common culprits:

- **Gradle eating RAM during APK build** — Tateru caps Gradle at 2GB (mod 9.x). If you see it above that, file a bug.
- **Multiple concurrent builds** — only run one build at a time.
- **Browser dev tools open** — Electron's DevTools can use 500MB+. Close them when not debugging.

### "Disk full mid-build" 

See [APK build issues — Disk full mid-build](#disk-full-mid-build) above. Settings → System Info shows your disk space + threshold colour.

### Pipeline takes longer than expected

Spec Approval Panel shows estimated build time based on your last 3+ similar-sized completed builds. If your build is consistently 2x longer:

- Check the per-agent breakdown in the post-build report (Pipeline page → **Build Report** button)
- Look for outlier durations on a single agent
- Common cause: Agent Orange running 5+ cycles. Try Sonnet → Opus to reduce cycle count
- Other cause: Doc-Tor on a model that struggles with long output (Haiku) — switch to Sonnet

---

## Specific error messages — alphabetical lookup

### `agent-orange failed: ENOENT: no such file or directory, open '...proguard-rules.pro'`

Cascading failure from a broken pubspec.yaml — see "Build pipeline issues / 'Failed to parse Doc-Tor JSON'" above.

### `ANTHROPIC_API_KEY not configured`

Set via Settings → AI Providers → Anthropic. If already set + still seeing this on Diagnose specifically, mod 10.104 (9.32.x+) added a cached client accessor — upgrade.

### `Bad escaped character in JSON at position N`

Doc-Tor or DocSmith emitted invalid JSON escape. Mod 10.115 + 10.131 (9.32.13+) state-machine repair fixes this. Upgrade.

### `Could not find a Flutter SDK`

Setup Wizard didn't detect Flutter. See [Setup Wizard issues / Flutter not detected](#flutter-not-detected) above.

### `cannot find symbol: class Registrar`

Either `file_picker 5.x/6.x` (Bob's SAFE_VERSIONS should pin to ^8.1.7) or `record 5.x` pulling in `record_linux 0.7.2`. See [APK build issues](#apk-build-gradle-issues) above.

### `Cloud sauce vN · offline` after a successful Pull

Cache populated, but cloud version-check endpoint isn't reachable from your install. As of 2026-05-23 the `/api/v1/rules/version` endpoint isn't deployed to Railway yet — your cached rules ARE working; the pill just can't confirm "latest" without verification. See [Cloud Sauce indicator](#cloud-sauce-indicator-sidebar-pill) above.

### `Expected ':' on line N column 1` (in pubspec.yaml)

Dart `//` comments leaked into pubspec content. Mod 10.130 (9.32.13+) defensive strip. Upgrade.

### `Failed to update packages` (during flutter pub get)

Either a hallucinated package name (see [Could not find package](#could-not-find-package-just_audio_equalizer)) OR a network issue — check your internet.

### `'rm' is not recognized` on Windows during website regenerate

Mod 10.125 (9.32.13+) cross-platform `fs.rm`. Upgrade.

### `spawn adb ENOENT`

ADB not on PATH. See [Send to Phone — Android — spawn adb ENOENT](#send-to-phone-android) above.

### `Validation error: errorSummary: String must contain at most 5000 character(s)`

Diagnose modal hit the server-side payload size limit. Mod 10.106 (9.32.x+) clamps client-side. Upgrade.

---

## Still stuck?

In rough order of speed-to-answer:

1. **Ask Bob** (sidebar) — Bob has read every Tateru doc + release note. Most user-facing questions get answered instantly. Free.
2. **Send Feedback** (sidebar) — bug reports + feature requests. Goes to support@tateru.app + Tateru's admin queue. Reply within 24 hours during beta.
3. **support@tateru.app** — direct email. Attach the support bundle (Settings → Diagnostics → Download Support Logs).
4. **GitHub Issues** at the public release repo — community-visible bug reports.

When reporting a bug, include:

- Tateru version (Settings → About)
- OS + version
- What you expected to happen
- What actually happened
- Steps to reproduce (most important — bugs without repro steps are very hard to fix)
- Support bundle attached

---

*See also: [USER_MANUAL.md](USER_MANUAL.md) for the full app reference, [SETTINGS_REFERENCE.md](SETTINGS_REFERENCE.md), [FAQ.md](FAQ.md).*
