---
**App:** Tateru Pro
**Version:** 1.0.0-beta.9.32.13
**Owner:** KangaBlue.au
**Contact:** support@tateru.app
**Last updated:** 2026-05-11
---

# Quick Start

A 10-minute walkthrough from "downloaded the installer" to "Android APK on your phone". For deeper detail on any step, see [USER_MANUAL.md](USER_MANUAL.md).

---

## 0. Prerequisites

Before you start:

- A computer running Linux, macOS, or Windows (64-bit)
- A Tateru Pro **invite code** (if you don't have one, request access at [tateru.app/beta](https://tateru.app/beta))
- An **Anthropic API key** (free to create — pay-as-you-go from $0.001 per build) — get one at [console.anthropic.com](https://console.anthropic.com)
- An Android phone (optional but recommended — without one you can't actually install the apps you build)
- ~5 GB of free disk space

Optional but useful:

- An **OpenAI API key** for the icon generator (DALL-E 3) and Clone-from-screenshots feature

---

## 1. Install Tateru (~3 min)

Download the latest release for your OS from [github.com/ushanboe/tateru-pro-releases](https://github.com/ushanboe/tateru-pro-releases/releases/latest).

| OS | File | What to do |
|---|---|---|
| **Linux** | `Tateru.Pro-*.AppImage` | `chmod +x` then double-click |
| **Linux (Debian/Ubuntu)** | `Tateru.Pro-*-amd64.deb` | `sudo dpkg -i Tateru.Pro-*-amd64.deb` |
| **macOS** | `Tateru.Pro-*-mac.zip` | Extract → drag to /Applications. First launch: right-click → **Open** to bypass Gatekeeper warning. |
| **Windows** | `Tateru.Pro-Setup-*.exe` (recommended) | Double-click. Click **More info** → **Run anyway** on the SmartScreen warning. NSIS installer creates Start Menu + Desktop shortcuts. |

Tateru opens to the **Setup Wizard** on first launch.

---

## 2. Setup Wizard (~3 min)

The wizard auto-detects what's installed on your machine + asks you for one API key. 6 steps:

1. **Welcome** — click Get Started.
2. **Flutter SDK** — auto-detected if installed. If missing, install Flutter from [flutter.dev/docs/get-started/install](https://flutter.dev/docs/get-started/install) (or click Skip — you can install later and come back via Settings).
3. **Android SDK + Java** — auto-detected. Install Android Studio if missing ([developer.android.com/studio](https://developer.android.com/studio)) — bundles both.
4. **AI Provider** — pick Anthropic, paste your API key, click Test connection. ✅ green check = good.
5. **How will you install apps?** — pick Wireless ADB (recommended) or USB Cable.
6. **Done** — click Continue to Register.

---

## 3. Register (~1 min)

Sign up with your email + invite code:

1. Email + password
2. Invite code (e.g. `BETA-XXXXXXXX`)
3. Accept Privacy + Terms checkbox
4. Click **Sign up**
5. Welcome email lands in your inbox; 14-day free trial starts

You're now on the Dashboard.

---

## 4. Build your first app (~10–25 min)

Sidebar → **AI Spec** → opens the chat-based spec builder.

Type your idea in plain English. Examples that work well for a first build:

- "A simple tip calculator with split-bill support"
- "An offline pomodoro timer with daily streak tracking"
- "A habit tracker for daily routines"

The Spec Chat agent will either:

- **Emit a JSON spec immediately** (if your description was concrete enough) — click "Use this spec"
- **Ask 2-4 clarifying questions** — answer them, then it produces the spec

You're taken to the **New Project page** with the spec pre-filled. Review it (you can edit features, owner email, etc.), then click **Create Project**.

You land on the **Pipeline page**. Click **Start Pipeline**.

### What happens next

10 named agents run in sequence (you'll see the tile light up green as each completes):

1. Distill (10-30s) — compress the spec
2. Research (30s-2min) — find similar apps + Flutter packages
3. Architect (1-5min) — combine sources into a build doc
4. Docs (3-15min) — write the full spec, file by file
5. **Spec Approval** — pipeline pauses; review estimated cost + ETA + dependencies → Approve
6. Build (8-35min) — Bob generates the actual code
7. Icons (15-30s) — DALL-E generates the app icon
8. Post Docs (2-5min) — write user-facing docs
9. Review (5-60min) — Agent Orange reads the code + fixes issues across 1-7 cycles
10. Test (30s-1min) — generate integration tests
11. Audit (1-5min) — verify every feature is wired

Then APK build runs (~3-8min).

For a tip calculator: ~15-20 min total, costs ~$3-8.

For a more complex app: ~30-90 min total, costs ~$10-30.

---

## 5. Install the APK on your phone (~2 min)

After the pipeline shows green across all phases + the APK builds successfully:

### Option A — Wireless ADB (no cable)

Set up once:

1. On your Android phone: Settings → About phone → tap **Build Number** 7 times
2. Settings → Developer Options → **Wireless Debugging** → toggle ON
3. Wireless Debugging → **Pair device with pairing code**
4. Note the IP:port + 6-digit pairing code your phone displays
5. In Tateru: open your project's **Code Workbench** (Pipeline page → **Open Workbench** button, or My Apps → click the row → Workbench tab) → switch to the **Deploy** tab → make sure **Wireless** mode is selected
6. Fill in the 4 fields (IP address, Pairing port, Pairing code, Connect port — all from your phone screen) → click **Pair & Connect**

Then to install:

7. Back on the Pipeline page → click **Install on Android** → pick your paired device → APK installs

### Option B — USB Cable

1. Plug your phone into your computer
2. Accept "Allow USB debugging?" on the phone
3. In Tateru: open your project's **Code Workbench** → **Deploy** tab → switch to **USB Cable** mode → click **Install via USB**, OR back on the Pipeline page click **Install on Android** → pick your USB device

The app appears on your phone's home screen. Open it. You're done.

---

## What's next?

Now that you've built your first app, explore:

- **Refinement Agent** — Pipeline page → Refine App. Type "Add a dark mode toggle" or any other change → 5-15 min later your APK has the change
- **Different Build Modes** — try Manual Entry for a hand-crafted spec, or Discover to find a Play Store opportunity to clone
- **Trend Cast** — sidebar → predict your app's launch performance before shipping
- **Website & Docs** — sidebar → generate a Next.js marketing website you can deploy to Vercel
- **Push to GitHub** — Pipeline page → push the project source to a new GitHub repo

For deeper detail on every Tateru feature, see:

- [USER_MANUAL.md](USER_MANUAL.md) — comprehensive reference for every UI element
- [BUILD_MODES_GUIDE.md](BUILD_MODES_GUIDE.md) — deep dive on each of the 6 build modes
- [GREENTHUMB_GUIDE.md](GREENTHUMB_GUIDE.md) — audit + website + docs flows
- [TRENDCAST_GUIDE.md](TRENDCAST_GUIDE.md) — launch prediction
- [SETTINGS_REFERENCE.md](SETTINGS_REFERENCE.md) — every setting field documented
- [TROUBLESHOOTING.md](TROUBLESHOOTING.md) — common issues + fixes
- [FAQ.md](FAQ.md) — frequently asked questions

Or just sidebar → **Ask Bob** and ask any question about Tateru directly.

---

## Common first-build issues

**Build keeps hanging on "Doc-Tor"** — switch Doc-Tor to Sonnet 4.6 in Settings → Build Model Config (Haiku is more prone to malformed JSON on long output).

**APK build fails with "cannot find symbol Registrar"** — old `file_picker` package issue. Mod 10.120 (9.32.12+) fixed this. Upgrade to the latest version.

**Wireless ADB pair times out** — pairing code expires after ~60 seconds. Get a fresh one from your phone, retype quickly.

**"Tateru opens to a blank window"** — see [TROUBLESHOOTING.md / Tateru opens to a blank window](TROUBLESHOOTING.md#tateru-opens-to-a-blank-window).

For anything else, sidebar → **Ask Bob**.

---

*Welcome to Tateru. Build something cool.*
