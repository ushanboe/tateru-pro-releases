# User Manual

**App:** Tateru Pro
**Audience:** Reference for every feature in Tateru Pro.

This manual covers what each part of the app does, how to use it, and what to do when it doesn't behave the way you expect. For a friendly walkthrough, start with the [Quick Start Guide](#).

---

## Sidebar overview

| Section | What it does |
|---|---|
| **Dashboard** | Your home — recent activity, project counts, system health |
| **My Apps** | Every project you've built or imported |
| **Build Modes** — Discover / AI Spec / Manual Entry / JSON Upload / Clone App / Import Project | Six ways to start a new app |
| **App Polishers** — Trend Cast / Website & Docs | Tools that run on a finished app to validate market fit + generate marketing collateral |
| **Analytics** | Aggregate stats across your projects |
| **Support** | Contacts / Send Feedback / Ask Bob / User Manuals / FAQ |

---

## Build Modes

### Discover (AppScout)

Mines the Play Store for app categories with high demand and weak existing offerings.

1. Pick a category (productivity, health, finance, etc.) and a brief search.
2. Scout agent scans the top 200 apps in that segment, mines reviews for complaints + feature gaps.
3. Returns a ranked list of opportunities with scores 1–10.
4. Click a row → **Deep Dive Brief** — full app spec written by an LLM, ready to feed into Build.

### AI Spec

Conversational spec-builder. Tateru asks 3–5 questions to disambiguate your idea, then produces a structured app spec (features, screens, data model, AI enhancements).

Best when you have a description but haven't pinned down details. The model defaults to Claude Sonnet 4.6 for code-quality.

### Manual Entry

Form-based app builder. You fill in:
- App name + tagline
- Category + target audience
- Core features (toggle on/off + edit)
- AI enhancements (toggle on/off)
- Tech stack (defaults to Flutter + SQLite + ChangeNotifier)

Best when you know exactly what you want.

### JSON Upload

Paste a complete app spec as JSON. Power-user mode — useful for batch builds or when iterating on an existing spec without going through the wizard again.

### Clone App

Reverse-engineer an app from screenshots. Drop 1–8 PNGs of an existing app — GPT-4o-mini analyzes the UI and produces a Tateru-shaped spec. Edit, then build.

### Import Project

Bring an existing `.tateru-project` archive from another machine. The full source, agent logs, and project status come across. If a project with the same slug already exists, you'll be asked to **Replace existing project** or **Cancel**.

---

## The Build Pipeline

Every Tateru app goes through 10 agents (the Pipeline page on a project shows them as tiles).

| Agent | Phase | What it does |
|---|---|---|
| Distiller | Distill | Compress the brief into a tight spec |
| Thinker Bell | Research | Find similar apps + relevant Flutter packages |
| Build Architect | Architect | Assemble all sources into a single coherent build doc |
| Doc-Tor | Docs | Write the build specification — every screen, widget, data flow |
| Bob the Builder | Build | Generate the Flutter code |
| Icon Generator | Icons | Generate app icon (DALL-E 3 + Sharp resize) |
| DocSmith | Post Docs | Write user-facing docs (Privacy, Terms, User Manual, FAQ, Quick Start) |
| Agent Orange | Review | Review code + fix issues (1–3 review cycles) |
| Test Generator | Test | Generate integration tests |
| Feature Auditor | Audit | Verify every feature actually works |

Then **APK build** runs automatically. Total time: 10–25 minutes for typical apps.

### Refine after build

If something's off, use the **Refine App** panel on the Pipeline page:

- **Preset fixes** — buttons for common issues (themes, fonts, back buttons, dark popups, empty screens, biometrics).
- **Custom instruction** — describe your fix in plain English.

Refinement Agent edits the files. Click **Rebuild APK** → install.

---

## Models — what runs where

Settings → **Build Model Config** lets you pick which AI model runs each agent. Tateru ships with five presets:

Costs below are calibrated against real-world spend on Phase 20–22 builds (Retrowind, ClassiPod, Rewind, Hauntly) for a typical 9–20-file app. Tiny utilities cost less, complex multi-screen apps with AI features cost more.

| Preset | Cost / build | Build time (typical app) | Quality | Best for |
|---|---|---|---|---|
| **Budget** | ~$1–$4 | 20–40 min | Basic | Prototyping ideas |
| **Balanced** | ~$6–$20 | 30–60 min | High | Most builds (recommended) |
| **Premium** | ~$20–$50 | 30–60 min | Best | Complex apps, critical builds |
| **DeepSeek Hybrid** | ~$4–$10 | 30–60 min | High | Cost-saver — DeepSeek on analysis, Sonnet on code-gen |
| **Hybrid Cloud + qwen3** | ~$2–$6 | 30–60 min | High | Requires Ollama Cloud subscription |

Refinement cycles add ~$1–$6 each (5–15 min) on top of the initial build.

You can also customize per-agent — e.g. Haiku for cheap analysis, Sonnet for Bob + Agent Orange + Doc-Tor (the agents where quality matters most).

---

## Deploy

### Android APK

After build completes:

- **Install on Android** — uses ADB to push the APK to a connected phone. Plug in via USB (with USB debugging enabled) or pair wirelessly via Settings → Wireless ADB.
- **Rebuild APK** — re-runs gradle. Useful after manual code edits.
- **Save Locally** — copy full source + APK to a folder on your machine (initialises a git repo).
- **Push to GitHub** — push the project source to a new GitHub repo (needs a personal access token with `repo` scope).

### iOS (macOS only)

Pipeline page → **iOS & macOS targets** section:

- **iOS Simulator** — pick a booted simulator, click **Install & Run on iOS**. No signing required.
- **Real iPhone** — one-time setup: open the project's `ios/Runner.xcworkspace` in Xcode, set your Apple Developer Team in Signing & Capabilities, save, quit. Then **Install & Run on iOS** with your iPhone selected. Tateru handles the rest.

### macOS app (experimental)

Same panel — **Build for macOS [exp]** produces an unsigned `.app.zip`. Most apps Bob generates compile cleanly for macOS even though they're Android-targeted.

---

## App Polishers

### Trend Cast

200-AI-agent simulation that predicts your app's launch performance. Pulls from real Play Store data + a custom audience model. Output: 15-section report covering download projections, monetization fit, top retention risks.

Run it before pushing to GitHub if you want a sanity check.

### Website & Docs (GreenThumb)

Builds a marketing website + audits the project's docs:

- **Step 1** — App identity + Quick Start / User Manual present + current
- **Step 2** — Privacy Policy + Terms of Use exist + match owner/email
- **Step 3** — App icon present
- **Step 4** — Web presence detected (or generates a Next.js marketing site you can deploy to Vercel)

### Generate Marketing Website

Builds a full Next.js site for your app — hero, features, screenshots, docs viewer, deploy buttons. Output lands at `~/.tateru-pro/websites/<AppName>-web/`. You can:

- **Open Preview** — local Next.js dev server on port 4000
- **Manage Screenshots** — drop PNGs into the manifest slots
- **Deploy** — push to Vercel via the integrated deployer
- **Download zip** — full site source as a zip
- **Regenerate Website** — rebuild with new content (preserves screenshots)

---

## Settings

Top-level configuration:

- **Account** — sign in/out, plan tier, billing
- **AI Providers** — API keys for Anthropic / OpenAI / Google / Moonshot / DeepSeek / Ollama Cloud
- **SDK Paths** — Flutter / Android SDK / Java JDK / Xcode / CocoaPods (auto-detected, manual override available)
- **Build Model Config** — choose presets or customize per-agent
- **Telegram Notifications** — get pinged when a build completes (or on Spec Ready for approval)
- **Build Learnings** — review/manage local rules learned from your builds, opt in/out of cloud sharing

---

## Common workflows

### "I want to iterate on an app on multiple machines"

1. Build the app on machine A.
2. **Export Project** (Pipeline page → top-right) → save the `.tateru-project` archive somewhere shared.
3. On machine B, sidebar → **Import Project** → drop the archive.
4. Status preserved as `READY` (no re-running the pipeline).
5. **Rebuild APK** locally — done.

### "My build failed — what next?"

1. Click **Diagnose** (purple button on the failed build) — Tateru's AI matches your error against its bug library + suggests a fix.
2. If the suggested action is "open Refine panel" → click that, the instruction is pre-filled.
3. Click **Refine** → fix is applied → **Rebuild APK**.
4. If Diagnose says "escalate" → email goes to support@tateru.app with diagnostics attached.

### "The audit says my docs are stale"

The audit runs a deterministic version-stamp check. Each doc has a header:
```markdown
**App:** AppName
**Version:** 1.0.0
**Owner:** Your Name
**Contact:** you@example.com
**Last updated:** 2026-05-07
```

If the doc's `**Version:**` doesn't match `pubspec.yaml`'s version, audit flags it as outdated. To fix: re-run **Refine** with instruction *"Update doc headers to version X.Y.Z"* OR generate fresh docs via the audit's **Generate** button.

---

## Privacy & data

- **All your projects** live on YOUR machine in `~/.tateru-pro/data/projects/` (or platform equivalent — see Settings).
- **API keys** are stored in OS keychain (macOS Keychain / GNOME Keyring / Windows Credential Manager) — never in plaintext.
- **Build telemetry** — sent to Tateru's cloud (anonymized error counts + agent timings) ONLY on Trial / Starter / Maker tiers. **Pro plan** = Private Build Mode = zero telemetry.
- **Project content** — never leaves your machine. Code, screenshots, names, your app idea — local only.

See [PRIVACY_POLICY.md](https://github.com/ushanboe/tateru-pro-releases/blob/main/docs/PRIVACY_POLICY.md) for the full policy.

---

## Where to get help

- **Send Feedback** (sidebar) — bug + feature requests
- **support@tateru.app** — email support, 24h response during beta
- **FAQ** — common questions

Last updated: 2026-05-07
