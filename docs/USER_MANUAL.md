---
**App:** Tateru Pro
**Version:** 1.0.0-beta.9.32.13
**Owner:** KangaBlue.au
**Contact:** support@tateru.app
**Last updated:** 2026-05-11
---

# Tateru Pro — User Manual

**Audience:** Anyone using Tateru Pro. New users start with the [Quick Start Guide](QUICK_START.md); this manual is the comprehensive reference for every feature, screen, button, and field in the app.

This is a long document organised by app section. Use the Table of Contents below to jump to what you need. Or, on any in-app screen, click **Ask Bob** in the sidebar — Bob is trained on this manual and will answer specific questions in plain English.

---

## Table of contents

1. [What is Tateru Pro?](#what-is-tateru-pro)
2. [Installing + first launch](#installing--first-launch)
3. [The sidebar — what each item does](#the-sidebar--what-each-item-does)
4. [Dashboard](#dashboard)
5. [My Apps](#my-apps)
6. [Build Modes — six ways to start a project](#build-modes--six-ways-to-start-a-project)
7. [The Build Pipeline — how an app gets made](#the-build-pipeline--how-an-app-gets-made)
8. [Refining a built app](#refining-a-built-app)
9. [Diagnose modal — what to do when builds fail](#diagnose-modal--what-to-do-when-builds-fail)
10. [Send to Phone — Android, iOS, macOS deploy](#send-to-phone--android-ios-macos-deploy)
11. [Trend Cast — predicting your app's launch performance](#trend-cast--predicting-your-apps-launch-performance)
12. [Website & Docs (GreenThumb) — marketing site + audit](#website--docs-greenthumb--marketing-site--audit)
13. [Save Locally / Push to GitHub / Export Project](#save-locally--push-to-github--export-project)
14. [Analytics](#analytics)
15. [Settings — every panel explained](#settings--every-panel-explained)
16. [Support — Send Feedback, Ask Bob, docs](#support--send-feedback-ask-bob-docs)
17. [Privacy & data — what stays local, what leaves your machine](#privacy--data--what-stays-local-what-leaves-your-machine)
18. [Plans, billing, and the trial](#plans-billing-and-the-trial)
19. [Where to get help](#where-to-get-help)

---

## What is Tateru Pro?

Tateru Pro is a desktop app that takes a one-paragraph idea for an Android (or iPhone, or macOS) app and turns it into a working installable APK in 10–60 minutes. You bring your own AI API keys (Anthropic + optional OpenAI / Google / DeepSeek / Ollama Cloud) — Tateru orchestrates them through a 9-agent pipeline that writes the spec, generates the code, draws the icon, writes the docs, reviews the code, generates tests, and audits every feature. When the pipeline completes, you get:

- A full Flutter source project on your local disk
- A signed-locally APK ready to install on a phone
- User-facing documentation (Privacy Policy, Terms, User Manual, FAQ, Quick Start, Test Plan)
- Optional: a Next.js marketing website you can deploy to Vercel
- Optional: a TrendCast launch-readiness prediction report

**Tateru is not a code generator you have to babysit.** It runs the full pipeline autonomously — including 1–5 review cycles where it reads its own code and fixes problems before declaring the app READY. If something needs human judgement, you get a Telegram notification (if configured) or see it on the Pipeline page.

**You own everything Tateru creates.** No royalties, no platform lock-in, no marketplace cut. Tateru's business model is the BYOK model + a flat subscription — no per-build fees from us (you pay your AI provider directly per build).

### What Tateru is NOT

- It is **not** a no-code visual builder. The output is real Flutter code you can edit by hand if you want.
- It is **not** a hosted service. Tateru runs as a desktop app on your machine — Linux, macOS, or Windows. Your projects, your code, and your API keys never leave your machine unless you explicitly publish them.
- It is **not** an app store. Building an app with Tateru gives you a project and an APK; publishing to the Play Store / App Store is your responsibility (we're working on a Play Store submission helper for a future release).
- It is **not** a chat-with-AI tool. The Ask Bob chat feature exists for support questions about Tateru itself — it doesn't write code on demand. Code generation happens through the build pipeline.

---

## Installing + first launch

### Where to download

Tateru is distributed via GitHub Releases at:

> https://github.com/ushanboe/tateru-pro-releases/releases/latest

Each release ships four artifacts:

| Platform | File | Size |
|---|---|---|
| Linux (AppImage) | `Tateru.Pro-<version>.AppImage` | ~250 MB |
| Linux (Debian/Ubuntu .deb) | `Tateru.Pro-<version>-amd64.deb` | ~180 MB |
| macOS (unsigned zip) | `Tateru.Pro-<version>-mac.zip` | ~210 MB |
| Windows (NSIS installer + zip) | `Tateru.Pro-Setup-<version>.exe` (installer, recommended) or `Tateru.Pro-<version>-win.zip` | ~210 MB |

Plus a `SHA256SUMS-<version>` file you can use to verify download integrity if you care about supply-chain security.

### Linux install

**AppImage:**

```bash
chmod +x Tateru.Pro-*.AppImage
./Tateru.Pro-*.AppImage
```

**Debian/Ubuntu .deb:**

```bash
sudo dpkg -i Tateru.Pro-*-amd64.deb
# Launch from your application menu, or:
tateru-pro
```

### macOS install

1. Double-click the `.zip` to extract `Tateru Pro.app`
2. Drag `Tateru Pro.app` to `/Applications`
3. **Important — first launch on macOS** triggers a Gatekeeper warning ("Tateru Pro can't be opened because Apple cannot check it for malicious software"). To bypass:
   - Right-click `Tateru Pro.app` in Finder → **Open** → **Open** in the dialog
   - OR, in Terminal: `xattr -d com.apple.quarantine "/Applications/Tateru Pro.app"`
4. Subsequent launches open normally without the warning

We don't ship a code-signed Mac binary yet because Apple Developer-level signing+notarization adds release-cycle complexity we deferred until post-beta. We'll sign in a future release.

### Windows install

**Recommended — NSIS installer (`.exe`):**

1. Double-click `Tateru.Pro-Setup-<version>.exe`
2. Windows shows "Windows protected your PC — Microsoft Defender SmartScreen prevented an unrecognised app from starting" because Tateru isn't code-signed yet
3. Click **More info** → **Run anyway**
4. Walk through the NSIS installer (defaults are fine — installs to `%LOCALAPPDATA%\Programs\Tateru Pro`)
5. Tateru appears in your Start Menu and (optionally) on your Desktop

**Alternative — ZIP (power users):**

1. Extract the `.zip` to anywhere you have write access (e.g. `C:\Tateru`)
2. Run `Tateru Pro.exe` directly
3. Note: zip install does NOT create Start Menu shortcuts. Pin the .exe to your Start Menu manually if you want them.

### Setup Wizard (first launch only)

The first time you launch Tateru, the **Setup Wizard** runs to make sure your machine has the SDKs Tateru needs. The wizard has six steps; you can use the **Skip** option on any step but you'll get warnings if a critical SDK is missing.

#### Step 1 — Welcome

Just an introduction. Click **Get started** to begin.

#### Step 2 — Flutter SDK

Tateru calls Flutter to compile generated code into APKs. The wizard auto-detects Flutter on common install paths (`~/flutter/bin`, `~/development/flutter/bin`, `/opt/flutter/bin`, Windows: `C:\src\flutter\bin\flutter.bat`, etc.).

- ✅ **Detected** — green check + Flutter version. Click **Next**.
- ❌ **Not found** — install Flutter first ([flutter.dev/docs/get-started/install](https://flutter.dev/docs/get-started/install)) then click **Re-detect**. Or paste a custom Flutter path into the override field (e.g. `C:\src\flutter\bin\flutter.bat`).
- The wizard runs `flutter --version` to verify.

#### Step 3 — Android SDK + Java

Required for compiling APKs. Tateru auto-detects:

- **Android SDK** — looks for `$ANDROID_HOME` env var first, then common locations: `~/Android/Sdk` (Linux), `~/Library/Android/sdk` (Mac), `%LOCALAPPDATA%\Android\Sdk` (Windows — Android Studio default).
- **Java JDK** — checks bundled JDKs in Android Studio + IntelliJ + JetBrains Toolbox first (most Android devs have THIS Java, never installed standalone Adoptium), then standalone installs of Adoptium / Oracle / Microsoft / Zulu / Amazon Corretto.

If both are detected, click **Next**. If either is missing, install Android Studio (which bundles both) — it's the fastest path. [developer.android.com/studio](https://developer.android.com/studio).

#### Step 4 — AI Provider

Pick your primary LLM provider and paste an API key.

- **Anthropic** (recommended) — used by all 9 build agents on the default "Balanced" preset. Get a key at [console.anthropic.com](https://console.anthropic.com).
- **OpenAI** (recommended) — used for the Icon Generator (DALL-E 3) and the Clone-from-screenshots feature. Get a key at [platform.openai.com](https://platform.openai.com).
- **Google** — used if you switch certain agents to Gemini in Build Model Config. Get a key at [aistudio.google.com](https://aistudio.google.com).
- **Moonshot** — used for the Kimi K2 model option. Get a key at [platform.moonshot.cn](https://platform.moonshot.cn) (Chinese site; English version exists).
- **DeepSeek** — used for the DeepSeek Hybrid preset (cheaper analysis agents). Get a key at [platform.deepseek.com](https://platform.deepseek.com).
- **Ollama Cloud** — used for the Hybrid Cloud + qwen3 preset. Subscribe at [ollama.com/cloud](https://ollama.com/cloud) ($20/mo Pro or $100/mo Max).

Click **Test connection** after pasting a key — Tateru calls each provider's "list models" endpoint to verify the key works. You can configure additional providers later in **Settings → AI Providers**.

#### Step 5 — How will you install apps?

Pick your typical deploy target:

- **Wireless ADB** (recommended for Android phones) — Tateru pairs over Wi-Fi, no cable needed. You'll need to enable Developer Options + Wireless Debugging on your phone first (Settings → About phone → tap Build Number 7 times → back to Settings → Developer Options → Wireless Debugging).
- **USB Cable** — classic ADB over USB. Plug in, accept the "Allow USB debugging?" prompt on your phone, done.
- **I'll set this up later** — skip this step.

#### Step 6 — Paths & Configuration

Optional power-user settings:

- **Website Output Directory** — where generated marketing sites land. Default: `~/.tateru-pro/websites/`. Override only if you need a specific location (e.g. inside a Vercel-deploy folder).
- **Ollama URL** — only relevant if you run Ollama on a non-default host/port or on a separate machine. Default: `http://localhost:11434`.

#### Step 7 — Done — Continue to Register

Wizard closes. You're taken to the **Register** screen where you create a Tateru Pro account and enter your beta invite code.

---

## The sidebar — what each item does

Tateru's sidebar is grouped into 6 sections. Each item links to a screen.

### Top group (no header)

| Item | What it does |
|---|---|
| **Dashboard** | Home page — recent activity, project counts, system health, quick links to common actions. |
| **My Apps** | List of every project you've built or imported. Sortable, searchable, click any row to open its Pipeline page. |

### Build Modes

Six ways to start a NEW app project. Each opens the New Project page in a different mode — see [Build Modes](#build-modes--six-ways-to-start-a-project) below.

| Item | When to use |
|---|---|
| **Discover** | You want Tateru to scan the Play Store and suggest opportunity gaps. |
| **AI Spec** | You have a fuzzy idea and want Tateru to ask clarifying questions. |
| **Manual Entry** | You know exactly what you want — fill in a form. |
| **JSON Upload** | You have a complete spec as JSON (power users / batch builds). |
| **Clone App** | You have screenshots of an existing app — Tateru reverse-engineers a spec. |
| **Import Project** | You have a `.tateru-project` archive from another machine. |

### App Polishers

Tools that run on a finished app (not used during the build itself):

| Item | What it does |
|---|---|
| **Trend Cast** | Predict launch performance — 200-AI-agent simulation + 15-section report. |
| **Website & Docs** | Generate a Next.js marketing website AND audit the project's docs (Privacy / Terms / Quick Start / User Manual / icons / web presence). |

### Standalone

| Item | What it does |
|---|---|
| **Analytics** | Aggregate stats across your projects — total spend, weekly/monthly trends, per-build cost detail. |

### Support

| Item | What it does |
|---|---|
| **Send Feedback** | Bug reports, feature requests, questions — goes to Tateru's support inbox + admin queue. |
| **Ask Bob** | Chat with Bob (powered by GPT-4o-mini) — ask any question about Tateru itself. Bob has read this manual. |
| **Quick Start** | The Quick Start Guide rendered in-app. |
| **User Manuals** | This manual rendered in-app. |
| **FAQ** | Frequently asked questions. |

### Settings (gear icon, bottom of sidebar)

Account, AI Providers, Build Model Config, Audit Model, SDK Paths, Telegram Notifications, Build Learnings, System Info, Diagnostics, About. See [Settings — every panel explained](#settings--every-panel-explained) below.

### Admin (only visible if `TATERU_ADMIN=1` was set at build time)

Internal-only docs for Tateru maintainers (architecture, capacity playbook, runbook, release process). Not visible in customer builds.

---

## Dashboard

The Dashboard is your home page after login. It has four sections:

### Recent activity

Shows the last 5 things that happened across your projects:
- "ProjectName build completed in 17m 22s"
- "ProjectName audit found 2 issues"
- "ProjectName APK installed on Pixel 8"
- etc.

Click any row to jump to that project's Pipeline page.

### Project counts

Three big numbers:
- **Active** — projects currently building (status: any pipeline phase)
- **Ready** — projects that built successfully (status: READY)
- **Failed** — projects whose pipeline crashed and weren't recovered (status: FAILED)

### System health (top-right corner)

Real-time read of your machine's resources — RAM used / total, CPU load, disk space on the Tateru data partition. Updates every 5 seconds. Useful when builds are running so you can spot if Gradle is eating all your RAM (capped at 2 GB by Tateru — see Settings → System Info).

### Quick links

Buttons for the most common actions:
- **Start a new project** → New Project (AI Spec mode)
- **My Apps** → list of all projects
- **Open Settings**

---

## My Apps

A table of every project you've created or imported. Columns:

| Column | What it shows |
|---|---|
| Name | App name. Click to open the Pipeline page. |
| Status | TEMPLATE (spec-only, not built yet) / various pipeline phases / READY / FAILED |
| Created | When you started the project |
| Last updated | When the pipeline last ran or you last edited |
| Files | Total file count |
| Cost | Total LLM spend on this project (sum of all pipeline runs + refinements) |
| Tokens | Total LLM tokens used |
| Actions | ⋯ menu — Open / Duplicate / Export / Delete |

Above the table, a **search box** filters by name + a **status filter** dropdown narrows by status.

The **+ New Project** button (top-right) takes you to the same place as Sidebar → AI Spec.

### Deleting a project

Click the ⋯ → **Delete**. You'll be asked to confirm. Deleting removes:
- The project row from your DB
- The on-disk source under `~/.tateru-pro/data/projects/<slug>/`
- The output APK under `~/.tateru-pro/data/output_apps/<slug>/`

It does NOT remove:
- Any GitHub repo you pushed to
- Any local-saved copy you made via "Save Locally"
- Any `.tateru-project` archive you exported

---

## Build Modes — six ways to start a project

Each mode opens the same New Project page, just with a different starting form. All modes feed the same pipeline downstream.

For a deeper walkthrough of each mode with screenshots and worked examples, see [BUILD_MODES_GUIDE.md](BUILD_MODES_GUIDE.md).

### Discover (AppScout)

**When to use:** you want Tateru to find an opportunity for you. You don't have a specific app in mind yet.

How it works:

1. Pick one of three sub-modes:
   - **Manual Search** — narrow by category, keyword, platform, downloads range, revenue range, desired features. Best when you have a vertical in mind (e.g. "fitness apps").
   - **Auto-Discovery** — Tateru picks a high-opportunity category for you. Optional category hint.
   - **Skills Match** — paste a public GitHub repo URL OR describe your tech stack. Tateru fetches your real languages + dependencies, then finds Play Store apps you could realistically build with that stack.
2. Tateru runs the **Scout pipeline** (3 agents):
   - **Market Scan** — pulls top 30–50 apps in your search criteria from the Play Store
   - **Review Miner** — extracts the top complaints + feature requests from each app's reviews
   - **Opportunity Scorer** — scores each app 1–10 based on market gap, AI enhancement potential, technical feasibility, revenue potential, and (for Skills Match) stack match
3. Results show as a ranked list with scores. Click any row to open the **Deep Dive Brief**:
   - Full spec for a competitor app — features, screens, AI enhancements, recommended tech stack
   - **Send to Build** button → takes the brief into the build pipeline (uses AI Spec mode under the hood)

**Field reference (Manual Search):**

- **Keyword Search** (free text, optional) — a Play Store search term. Examples: "habit tracker", "meal planner", "budget".
- **Category** (dropdown) — Play Store category. 33 options including All Categories, Productivity, Health & Fitness, Finance, Tools, etc.
- **Platform** (button group: Android / iOS / Both) — which app store to scan. Currently only Android is wired; iOS / Both display results from the Android scrape labelled accordingly.
- **Min Downloads** (dropdown) — filter out apps with fewer than this many downloads. Options: Any / 10K+ / 100K+ / 1M+ / 10M+.
- **Min Revenue** (dropdown) — filter by estimated monthly revenue. Options: Any / $1K+ / $5K+ / $10K+ / $50K+. Note: revenue estimates are derived from downloads + price + ad presence; not exact.
- **Desired Features** (free text, optional) — features you want the discovered apps to have. Filters opportunities to ones where these features could improve the user experience.

**Field reference (Auto-Discovery):**

- **Focus Category** (dropdown, optional) — pick a category to scan, or leave as "All Categories" for Tateru to pick.

**Field reference (Skills Match):**

- **Your Tech Stack / GitHub Repo URL** (textarea) — either paste a public GitHub URL (Tateru fetches languages + deps via the public API) OR describe your stack as free text (e.g. "React Native, TypeScript, Node.js, PostgreSQL, AWS, TensorFlow"). Both work — both flow through the same matcher.

### AI Spec

**When to use:** you have a description in your head but haven't pinned down the details. Best for rapid iteration.

How it works:

1. Tateru opens a chat panel. You type your idea in plain English ("a habit tracker for runners that uses AI to suggest custom training plans").
2. The Spec Chat agent asks 3–5 clarifying questions ("How should training plans adapt? Based on past performance, weather, training load?"). Answer each one.
3. After enough back-and-forth, Tateru produces a structured spec — features, screens, data model, AI enhancements — formatted as JSON in the chat. Above the JSON, a "Use this spec" button jumps you into the New Project review form.

**Model selection:** the Spec Chat dropdown defaults to **Claude Haiku 4.5** (cheap + fast). You can switch to Sonnet 4.6 for better questioning if your idea is complex; for simple ideas Haiku is fine.

**Field reference:**

- **Send a message** (chat input) — your description / answers
- **Model selector** (dropdown) — change which AI handles the conversation
- **Restart conversation** (button) — clear chat history and start over

### Manual Entry

**When to use:** you know exactly what you want and don't need the AI's help to spec it.

A form with the following sections:

- **Basic info**
  - **App Name** (required)
  - **Tagline** (1-line description shown on the home screen)
  - **Category** (dropdown — same Play Store categories as Discover)
  - **Target audience** (free text — "students aged 14-22", "small-business owners", etc.)
- **Description** (long text — what the app does in 2-5 sentences)
- **Core Features** (list — add/remove/edit, defaults to 5 stub features you can replace)
- **AI Enhancements** (list — toggle which features should use AI; for each, write a 1-sentence description of what the AI does)
- **Tech Stack** (read-only summary — shows the default Flutter + SQLite + ChangeNotifier stack; you can override per-agent in Settings → Build Model Config)
- **Owner Name** (your name — appears in Privacy/Terms)
- **Owner Email** (your support email — appears in Privacy/Terms + bug reports)

When the form is complete, click **Create Project** → takes you to the Pipeline page where you click **Start Pipeline** to begin the build.

### JSON Upload

**When to use:** you have a complete spec as JSON. Useful for batch builds, testing variations on a spec, or seeding the pipeline from another tool.

The page has a single textarea for pasting JSON. The schema is documented in the textarea's placeholder; minimal example:

```json
{
  "name": "MyApp",
  "description": "A habit tracker.",
  "platform": "android",
  "coreFeatures": [
    { "name": "Add habit", "description": "User adds a daily habit." },
    { "name": "Track streak", "description": "Daily check-in updates streak counter." }
  ],
  "aiEnhancements": [
    { "enhancement": "Smart reminders", "description": "AI suggests reminder times." }
  ],
  "ownerName": "Your Name",
  "ownerEmail": "you@example.com"
}
```

Click **Validate & Create** — Tateru parses the JSON, checks the required fields, then creates the project.

### Clone App

**When to use:** you want to reverse-engineer an existing app from screenshots.

How it works:

1. Click **Choose images** OR drag-and-drop 1–8 PNG screenshots of an app
2. Optional: app name + 1-line description (helps the analyzer)
3. Click **Analyze**
4. GPT-4o (vision) reads the screenshots and produces a Tateru-shaped spec — features, screens, data model, suggested tech stack
5. Spec opens in the New Project form for editing — you can add/remove features, adjust the description, change the icon, etc.
6. Click **Create Project** → into the pipeline

**Notes:**
- Quality depends on screenshot quality. Crop tightly, avoid blurry shots, include screens that show distinct features.
- 8 screenshots is the max — beyond that, you get diminishing returns on accuracy.
- This is the only build mode that uses an OpenAI key for the spec phase. Anthropic key is still used for code-gen.
- Cost: ~$0.05–$0.15 per Clone analysis (GPT-4o vision).

### Import Project

**When to use:** you exported a `.tateru-project` archive from another machine and want to continue working on it here.

How it works:

1. Click the **Import Project** card (or sidebar → Import Project)
2. Drag-and-drop a `.tateru-project` zip file
3. Tateru shows a preview of the contents (app name, file count, source machine, status when exported)
4. If a project with the same slug already exists locally, you're asked: **Replace existing project** OR **Cancel**
5. Click **Import** → archive extracts to `~/.tateru-pro/data/projects/<slug>/`, project row is created in your local DB

**What's preserved:**
- All source files (DB rows + on-disk)
- Agent logs from the source machine's pipeline run
- Project status (READY / FAILED — *not* mid-pipeline phases, those reset to TEMPLATE because the orchestrator state from the source machine doesn't apply locally)
- Owner name + email

**What's NOT preserved:**
- Output APK (binary differs per machine — rebuild locally)
- API keys (always machine-local)
- License JWT (machine-local)
- Build settings (e.g. Telegram bot token — machine-local)

After import, the project shows status READY (if the source pipeline completed) — no need to re-run the LLM agents. Just click **Rebuild APK** locally to compile a new APK from the imported source.

---

## The Build Pipeline — how an app gets made

Every Tateru app goes through 9 named agents in sequence. The Pipeline page shows them as tiles across the top of the page. Each tile lights up as the agent runs — yellow while in progress, green when complete, red on failure.

| # | Agent | Phase label | What it does | Typical duration | Typical cost |
|---|---|---|---|---|---|
| 1 | Distiller | Distill | Reads your spec, compresses to ~1500 tokens preserving every feature | 10–30 sec | $0.001–$0.05 |
| 2 | Thinker Bell | Research | Finds 3–6 similar apps + relevant Flutter packages | 30 sec – 2 min | $0.005–$0.10 |
| 3 | Build Architect | Architect | Combines all sources into a single coherent build doc; classifies each feature as Functional / Needs Cloud / Not Buildable | 1–5 min | $0.05–$0.50 |
| 4 | Doc-Tor | Docs | Writes the full build specification — every screen, widget, navigation, data model. Output: 30K–80K tokens of structured JSON | 3–15 min | $0.30–$1.50 |
| 5 | Bob the Builder | Build | Generates the actual Flutter code, file by file. Picks one of 3 build strategies based on file count: single-pass (1–8 files), two-phase (9–20 files), four-phase (21+ files) | 8–35 min | $5–$25 |
| 6 | Icon Generator | Icons | Calls DALL-E 3 to generate the app icon, then resizes to all required Android densities (mipmap-mdpi through xxxhdpi) + adaptive icon foreground + iOS sizes | 15–30 sec | $0.04 (DALL-E flat fee) |
| 7 | DocSmith | Post Docs | Writes user-facing docs — Privacy Policy, Terms of Use, User Manual, FAQ, Quick Start, Test Plan — using your project's owner name + email | 2–5 min | $0.05–$0.20 |
| 8 | Agent Orange | Review | Runs `flutter analyze`, fixes errors, re-runs, repeats up to 7 cycles. Catches type errors, missing imports, broken Riverpod providers, etc. | 5–60 min | $5–$30 (most expensive on complex apps) |
| 9 | Test Generator | Test | Writes integration tests as `integration_test/app_test.dart` (does not execute them — that's a future "Run Tests on Device" feature) | 30 sec – 1 min | $0.02–$0.10 |
| 10 | Feature Auditor | Audit | Verifies every feature in the spec is actually wired in the generated code | 1–5 min | $0.10–$5 |

Then **APK build** runs automatically (~3–8 min, costs nothing — runs locally). Total end-to-end: **15–90 min** for typical apps; complex multi-screen apps with AI features may take longer.

### Spec Approval Panel (gate before Bob runs)

After Doc-Tor completes, the pipeline pauses at the **Spec Approval Panel**. This is your chance to review what Bob will build before incurring the bulk of the cost (Bob is 50–70% of total spend on most builds).

What you see:

- **Project overview** — app name, description, target platform
- **Estimated build time** — derived from your last 3+ similar-sized completed builds (or calibrated defaults if you don't have history yet)
- **Estimated cost (BYOK)** — same source — calibrated against actual Phase 20–22 spend
- **Estimated disk needed** — based on file count + recommended headroom; warns if your free disk is < estimate
- **Free disk now** — reads via Node's `statfs` cross-platform
- **Navigation type** — bottom tabs / drawer / stack-only
- **Dependencies** — list of pubspec packages Bob will use
- **File manifest** — every file Bob will create with a 1-line purpose

Buttons:

- **Approve & Continue** — Bob starts; you can leave the page and come back
- **Reject** — opens a modal where you write feedback for Tateru ("the spec misses X" / "I don't want feature Y") → returns to the Doc-Tor phase with your feedback to regenerate the spec
- **Edit spec manually** — opens the build doc in a JSON editor (power-user mode; use sparingly)

### Telegram approval (optional)

If you've configured Telegram in Settings, when the spec is ready you get a Telegram message with the spec summary + Approve / Reject inline buttons. Useful when the build runs on your desktop and you're away — you can approve from your phone. See [Settings → Telegram Notifications](#telegram-notifications) below.

### What "review cycles" mean (Agent Orange)

Agent Orange is the most expensive agent in the pipeline because it runs in a loop:

1. Agent Orange reads all of Bob's output
2. Runs `flutter analyze` on the project — gets a list of errors and warnings
3. For each error, edits the offending file to fix it
4. Re-runs `flutter analyze`
5. If errors remain AND we haven't hit the 7-cycle limit, go back to step 3
6. If `flutter analyze` is clean, run `flutter build --debug` as a final compile check
7. If compile passes, declare REVIEW PASSED and move to TEST phase

Each cycle takes 5–15 minutes on Sonnet. Most builds clear in 1–3 cycles; complex apps with AI features can need 5+. The Pipeline page shows a stack of timer chips under the Review tile (`c1·9m 29s`, `c2·11m 02s`, etc.) so you can see the pattern.

If Agent Orange exhausts all 7 cycles without clearing, the pipeline marks status FAILED. You can still click Diagnose to figure out what went wrong, OR click Refine to try a manual fix.

### What gets generated on disk

When the pipeline completes, your project lives at `~/.tateru-pro/data/projects/<slug>/`. Standard Flutter project layout:

```
projects/<slug>/
├── pubspec.yaml              ← Bob's generated dependency list
├── pubspec.lock              ← resolved versions (after flutter pub get)
├── lib/
│   ├── main.dart             ← app entry point
│   ├── core/                 ← theme, navigation, shared utilities
│   ├── features/             ← one folder per major feature
│   ├── data/                 ← repositories, models, DB
│   ├── widgets/              ← reusable UI components
│   └── ...
├── android/                  ← generated by `flutter create --platforms=android`
├── ios/                      ← generated only if iOS target was selected (Mac only)
├── integration_test/
│   └── app_test.dart         ← Test Generator's output
├── PRIVACY_POLICY.md         ← DocSmith
├── TERMS_OF_USE.md           ← DocSmith
├── USER_MANUAL.md            ← DocSmith (about your APP, not Tateru)
├── QUICK_START.md            ← DocSmith
├── FAQS.md                   ← DocSmith
├── TEST_PLAN.md              ← DocSmith
└── (after APK build) build/app/outputs/flutter-apk/app-release.apk
```

The APK also gets copied to `~/.tateru-pro/data/output_apps/<slug>/<slug>.apk` for easier access.

---

## Refining a built app

After a build completes, the **Refine App** panel appears on the Pipeline page. This is where you fix issues, add features, or change behaviour without re-running the whole pipeline.

### How Refinement works

1. You describe a fix or change in plain English
2. The **Refinement Agent** reads your project's current code, decides which files need editing, makes the edits
3. You click **Rebuild APK** to compile a new APK with the changes
4. Install on your phone, check the result, repeat if needed

A typical refinement loop is 5–15 minutes and costs $0.50–$5.

### Common issue presets

The Refine panel shows quick-action buttons for issues we see beta testers hit often:

- **Themes don't change** — replaces hardcoded colours with `Theme.of(context)` lookups so the theme switcher actually works
- **Missing back buttons** — adds AppBar with back button to every nested screen
- **Font changes don't apply** — removes hardcoded `fontFamily` so `ThemeData.fontFamily` is honoured globally
- **Dark text on dark popups** — adds explicit white text colour on SnackBars + Dialogs
- **Empty screens / no data** — adds realistic seed data on first launch
- **Biometrics not working** — adds USE_BIOMETRIC + USE_FINGERPRINT permissions, wraps biometric calls in try/catch

Click a preset → its instruction is loaded into the input field → click Refine to send it.

### Custom instructions

Just type in plain English what you want. Examples that work well:

- "Replace the gradient header with a solid colour matching the brand"
- "Add a search box at the top of the Library screen that filters songs by title"
- "When the user taps Settings, push a new screen instead of opening a modal"
- "Convert the bottom tabs to a drawer"

The Refinement Agent IS allowed to:
- Edit Dart files
- Add or remove pubspec dependencies
- Edit AndroidManifest.xml + MainActivity.kt (mod 10.55+)
- Run `flutter pub get`

It is NOT allowed to:
- Drop tables in the project DB (you'd lose state)
- Push to git
- Send emails or call external APIs

### Refinement cost + tokens

The Refinement panel shows your cumulative refinement cost + tokens at the top, e.g.:

> Refinement so far: 67K tokens · $0.24

This counts ALL refinement passes you've run on this project to date (not just the latest). Helps you decide whether to keep iterating or accept the current state.

### Rebuild APK

After Refinement edits the files, click **Rebuild APK**. This:

1. Reads the latest source from `projects/<slug>/`
2. Runs `flutter pub get` (in case dependencies changed)
3. Runs `flutter build apk --release`
4. Copies the new APK to `output_apps/<slug>/`

Takes 3–8 minutes. The Build Console shows live gradle output.

If Rebuild APK fails, the Diagnose button appears in the Build Console — click it to get an AI-suggested fix (see next section).

---

## Diagnose modal — what to do when builds fail

When something fails (pipeline phase, APK rebuild, audit step), Tateru surfaces a **Diagnose** button. Click it.

### What Diagnose does

1. Tateru collects the error context — failure summary, last 100 lines of build log, your project's pubspec, the agent that failed, the failed phase
2. Sends this to Anthropic Claude (using YOUR Anthropic key — not Tateru's)
3. Claude is given Tateru's MISTAKES library (a curated list of 130+ known failure patterns + their fixes) as context
4. Claude returns a confidence rating (low/medium/high), the matched rule, what's happening, suggested fix, and (when applicable) a Refinement instruction you can copy-paste

Cost: $0.20–$0.40 per Diagnose. Latency: 20–40 seconds.

### Reading the Diagnose result

- **Confidence: HIGH** + matched rule → very likely a known failure pattern. Try the suggested fix first.
- **Confidence: MEDIUM** → close to a known pattern but the symptom is slightly different. Read the suggestion carefully — adapt as needed.
- **Confidence: LOW** → no good match in the bug library. The suggested fix is more of a hypothesis. Try it, but expect to iterate.

### What to do after Diagnose

Three buttons at the bottom of the Diagnose result:

- **Save this fix to local learnings** (green) — click AFTER you've verified the fix worked. Saves the pattern to `~/.tateru-pro/data/local-mistakes.md`. On future builds, Bob will see this learning and avoid the same bug. Optionally (if the Build Learnings share toggle is ON in Settings), the learning is shared back to Tateru's cloud admin queue 48 hours later.
- **Open Refinement panel** — if the suggested action is to refine, this opens the Refinement panel with the suggested instruction pre-pasted. Just click Refine.
- **This didn't help — escalate** — opens your email client with a prefilled support@tateru.app email. Includes the project ID, error summary, and the failed Diagnose attempt.

### Copy refine instruction button

The Refine instruction has a small **Copy to clipboard** button that flashes "Copied!" for 2 seconds when clicked. Use this to paste into the Refinement panel manually if you don't want to use the Open Refinement Panel button.

---

## Send to Phone — Android, iOS, macOS deploy

After your APK builds, you have multiple ways to install it.

### Android — Install on Android button

The simplest path. Available on the Pipeline page after the APK is built.

1. Click **Install on Android**
2. Tateru lists detected devices (Android phones connected via USB or Wireless ADB)
3. Pick a device → APK installs
4. App appears on the device, ready to launch

If no devices appear, you need to **pair a device first** — see Wireless ADB Pair below.

### Android — Wireless ADB Pair

If your phone supports Wireless Debugging (Android 11+), you can deploy without a USB cable.

1. On your phone: Settings → About phone → tap Build Number 7 times (enables Developer Options if not already on)
2. Settings → Developer Options → Wireless Debugging → toggle ON
3. Wireless Debugging → **Pair device with pairing code** (NOT QR code — Tateru uses the code path)
4. Your phone shows: IP:port + 6-digit pairing code
5. In Tateru: open the project's **Code Workbench** page (My Apps → click your project → top tabs → **Workbench** button, OR sidebar → My Apps → click the row → use the **Open Workbench** button on the Pipeline page) → switch to the **Deploy** tab → make sure **Wireless** mode is selected (toggle in the Deploy panel; the alternative is **USB Cable** mode)
6. Enter the 4 fields:
   - **IP address** (from your phone — e.g. `192.168.1.42`)
   - **Pairing port** (from your phone — usually 5-digit, e.g. `41234`)
   - **Pairing code** (6 digits)
   - **Connect port** (usually shown above the pairing dialog on your phone — e.g. `40123`)
7. Click **Pair & Connect** — Tateru runs `adb pair` then `adb connect`, verifies the device appears in `adb devices` with status `device`
8. Done. Future Install on Android calls find this device automatically until you toggle Wireless Debugging off.

If the pair fails, common causes:
- Wrong port — pairing port and connect port are DIFFERENT (the phone displays both, easy to mix up)
- Phone went to sleep mid-pair (the pairing code expires after ~60 sec)
- Phone and PC on different networks (use the same Wi-Fi network)

### Android — USB Cable

1. Plug phone in via USB
2. On the phone, accept the "Allow USB debugging?" prompt (check "Always allow from this computer" to skip on future connects)
3. Either:
   - **Pipeline page** → click **Install on Android** → pick your USB device → install, OR
   - **Code Workbench → Deploy tab** → switch to **USB Cable** mode → click **Install via USB**

### Where the deploy UI lives — quick map

A common question: "I see Wireless ADB / USB references in the docs but where do I actually find the buttons?"

| Action | Where |
|---|---|
| Pair an Android phone wirelessly (one-time setup) | **Code Workbench → Deploy tab → Wireless mode** |
| Install via USB cable | **Code Workbench → Deploy tab → USB Cable mode**, OR Pipeline page → Install on Android |
| Install on a paired/connected device after each build | **Pipeline page → RefinementPanel → Install on Android button** |
| iOS Simulator + iPhone install (Mac only) | **Pipeline page → MultiTargetDeploy panel** |
| Build for macOS .app (Mac only, experimental) | **Pipeline page → MultiTargetDeploy panel** |

Wireless ADB pairing is in the Workbench because it's a per-project workspace tool. After you've paired once, the device persists across all your projects until Wireless Debugging is toggled off on the phone — so subsequent installs use the lighter Pipeline page button.

### iOS Simulator (Mac only)

The Pipeline page → **iOS & macOS targets** section appears on macOS hosts.

1. Open the Simulator app first (if not running)
2. In Tateru: **iOS Device** dropdown shows booted simulators + connected real iPhones
3. Pick a simulator (e.g. "iPhone 16 (iOS 18.2)")
4. Click **Install & Run on iOS**
5. Tateru runs `flutter build ios --simulator --debug` → `xcrun simctl install booted` → `xcrun simctl launch booted <bundle-id>`
6. App opens in the Simulator

### iOS — Real iPhone (Mac only, requires Apple Developer account)

One-time setup per project:

1. After the project's iOS scaffold exists (first iOS build creates it), open the project in Xcode:
   ```bash
   open ~/.tateru-pro/data/projects/<slug>/ios/Runner.xcworkspace
   ```
2. In Xcode → Runner target → **Signing & Capabilities** tab → check **Automatically manage signing** → pick your Apple Developer Team
3. Save. Quit Xcode.

Now you can install:

1. Plug your iPhone in (USB)
2. Trust the computer prompt on the iPhone
3. In Tateru: pick your iPhone from the iOS Device dropdown
4. Click **Install & Run on iOS**
5. Tateru runs `flutter build ios --release` (signed with your dev team's automatic-managed cert) → `flutter install -d <udid>` → `xcrun devicectl device process launch`

If the team isn't set, you get a clear error: *"No Apple Developer Team is set in <absolute-path-to-pbxproj>. Open <abs-path-to-Runner.xcworkspace> in Xcode and set your team in Runner → Signing & Capabilities"*. Mod 10.75+ preserves your team setup across rebuilds (older versions wiped it on every iOS rebuild).

### iOS — Connection Test diagnostic (Mac only)

Next to the iOS Device dropdown, a small 🩺 stethoscope button opens the **iOS Connection Diagnostic** modal:

- Lists all 3 device-detection sources Tateru uses: `xcrun simctl list devices`, `flutter devices --machine`, `xcrun xctrace list devices`
- Shows raw output from each (toggle to view)
- Suggests fixes for common detection failures

Use this when your iPhone is plugged in but doesn't appear in the dropdown.

### macOS .app build (Mac only, experimental)

Pipeline page → **iOS & macOS targets** → **Build for macOS [exp]** button.

- Runs `flutter build macos --release` against your project's existing source (Bob's Android-spec output is mostly cross-platform)
- Output: `~/.tateru-pro/data/output_apps/<slug>/<slug>-mac.app.zip`
- Unsigned — same Gatekeeper bypass as Tateru itself when you launch
- Most apps build cleanly; runtime feature parity is ~50% (on-device LLM features need iOS/Mac equivalents that Bob doesn't always pick automatically)

This is a roadmap-stage feature. Use it to prove a concept; don't ship to the Mac App Store from here yet.

### Diagnose for iOS / macOS errors

Both iOS and macOS builds have their own Diagnose buttons in the BuildConsole when something fails. Same flow as the Android Diagnose — Claude matches the error against MISTAKES rules and suggests a fix. The Diagnose request includes a `target: 'ios' | 'macos'` field so the matcher prefers target-relevant rules.

---

## Trend Cast — predicting your app's launch performance

Sidebar → **Trend Cast** → opens the Validate page.

### What it does

A 200-AI-agent simulation that predicts how your app will perform if you ship it to the Play Store. Each "agent" represents a synthetic user with a profile (demographics, app preferences, willingness to pay, retention behaviour). They evaluate your app's hero copy + screenshots + features and report:

- Likelihood to install
- Likelihood to keep past day 1 / day 7 / day 30
- Willingness to upgrade to a paid tier
- Top objections + concerns

Outputs aggregated into a **15-section report**:

1. Executive summary (TL;DR + recommended action)
2. Download projections (week 1 / month 1 / month 3 / month 6)
3. Monetization fit (free vs freemium vs paid; price elasticity)
4. Top retention risks
5. Top conversion blockers (for freemium → paid upgrade)
6. Audience segmentation (who actually liked it vs who skipped)
7. Sentiment heatmap (per app feature)
8. Competitive positioning
9. Marketing channel fit (which channels would convert best)
10. App Store listing critique
11. Onboarding friction analysis
12. Pricing recommendations
13. Feature prioritisation (what to build next)
14. Pre-launch action items
15. Post-launch monitoring KPIs

### How to run it

1. Sidebar → Trend Cast
2. Fill the form:
   - **App Name** (required)
   - **Description** (long text — what the app does + who it's for)
3. Click **Run prediction**
4. Tateru's TrendCast sidecar (a Python FastAPI process running on your machine, port 5101 — auto-started) runs the simulation. Takes 2–5 minutes.
5. Result: full 15-section report, paginated, exportable as PDF

### Cost

TrendCast uses your configured LLM provider (default: same as your Build Model preset). Typical run: ~$3–$15 depending on model + simulation depth. Heavier presets give more nuanced agent personas; lighter presets run faster + cheaper.

### When to use TrendCast

- **Before pushing a project to GitHub / Play Store** — sanity check; might surface obvious problems with your value prop or monetization
- **Comparing two app concepts** — run both, pick the one with the stronger projection
- **Validating a Discover opportunity** — Discover suggested an app idea; TrendCast tells you whether it's likely to actually take off

For full TrendCast documentation including the simulation methodology, see [TRENDCAST_GUIDE.md](TRENDCAST_GUIDE.md).

---

## Website & Docs (GreenThumb) — marketing site + audit

Sidebar → **Website & Docs** → opens the GreenThumb audit + website-generation page.

GreenThumb has two distinct purposes:

1. **Audit** — runs 4 quality checks on your project (docs / legal / icon / web presence)
2. **Marketing site generator** — builds a Next.js site you can deploy to Vercel

Both flows share the same Audit Job — you start by feeding GreenThumb a project, then both audit + website actions run against that job.

### Starting an audit

You can reach GreenThumb three ways:

1. From the Pipeline page → **Send to GreenThumb** button (most common — uses your Tateru-built project)
2. From the GreenThumb home → **Load Local Repo** → pick a folder on disk
3. From the GreenThumb home → **Load GitHub Repo** → paste a repo URL + (optionally) a personal access token for private repos

In all 3 cases, an `AuditJob` is created. The job has 4 steps that run sequentially.

### Step 1 — Identity & Docs

Two agents run in parallel:

- **App Summary Agent** — reads README + main.dart + 1–3 representative screen files → produces `appName`, `appDesc`, list of detected features. This is what populates "App Name" and "Description" fields downstream.
- **Doc Audit Agent** — looks at the file tree for `QUICK_START.md`, `USER_MANUAL.md`, `README.md` (canonical UPPERCASE root paths OR legacy `docs/<lowercase>.md`). Reports:
  - Quick Start: present / missing / current / outdated
  - User Manual: present / missing / current / outdated
  - "Current" = doc has a `**Version:** X.Y.Z` stamp matching the version in `pubspec.yaml`
  - Detection is filesystem-first — the LLM is consulted only for content quality, never for "does this file exist"

### Step 2 — Legal compliance

**Legal Audit Agent** — looks for `PRIVACY_POLICY.md` + `TERMS_OF_USE.md`. For each:

- ✅ / ❌ Present
- ✅ / ❌ Owner name matches expected (from project's `template.ownerName`)
- ✅ / ❌ Contact email matches expected (from project's `template.ownerEmail`)

When email mismatches, the audit log shows what email was actually found in the doc — useful for debugging.

### Step 3 — Icon

**Icon Agent** — finds the app icon, extracts to a temp file, displays in the audit report. Preference order:

1. `android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png` (highest density)
2. → mipmap-xhdpi → mipmap-hdpi → mipmap-mdpi
3. → `assets/icon.png` (if you have one)
4. → iOS / macOS scaffold default (would be a Flutter placeholder — flagged as "default icon detected, replace before shipping")

The icon is shown alongside a button to **Regenerate Icon** (calls DALL-E with your app's name + description).

### Step 4 — Web Presence

**Web Presence Agent** — searches for an existing website for your app (Google, Bing, GitHub Pages, common hosting providers).

- ✅ Found → URL displayed, SEO snippet preview
- ❌ Not found → "Generate Marketing Website" button appears (see below)

### Generate Marketing Website

If your app doesn't have a website yet (or you want to regenerate one), click **Generate Website**.

Pre-flight modal — the **Content Review Modal**:

1. **Features** — edit the auto-extracted feature list. Remove incorrect entries (e.g. permissions misclassified as features), add missing ones.
2. **Brand Colour** — colour picker + 8 swatch presets (Blue, Indigo, Purple, Pink, Red, Amber, Green, Cyan). Pick one or paste a hex.
3. **Marketing Angle** — required (since 9.32.13). Pick one of 5 presets:
   - **AI-First** — emphasises AI features, on-device LLM, zero API costs
   - **Privacy-Focused** — data stays on device, no cloud, no tracking
   - **Consumer Friendly** — simple language, lifestyle benefits, no jargon
   - **Developer Tool** — technical language, APIs, extensibility, performance specs
   - **Performance** — speed, battery efficiency, small size, fast startup
   
   Or write your own custom brief in the textarea.

4. **Chatbot Model** — picks which AI powers the marketing site's chat widget:
   - **No Chatbot** — ship the site WITHOUT a chat widget
   - **GPT-4o Mini** (recommended default) — cheapest, fastest
   - **GPT-4o** — smarter, ~10× cost
   - **Claude Haiku 4.5** — Anthropic-side option
   - **Claude Sonnet 4.6** — best quality, highest cost
   
   You'll need to set the matching env var (`OPENAI_API_KEY` or `ANTHROPIC_API_KEY`) on your deploy host (Vercel/Netlify) — Tateru shows you which.

5. **Approve & Generate** — click to start.

Pipeline (~3–8 min):

- Copy the marketing-web template to `~/.tateru-pro/websites/<AppName>-web/`
- Generate hero / features / requirements / chatbot sections (LLM)
- Render Privacy / Terms / User Manual / Quick Start as HTML pages
- Generate matching PDFs (if Puppeteer's Chromium is installed; otherwise PDF download links 404 — HTML pages still render)
- Sites live in `~/.tateru-pro/websites/<AppName>-web/`. AuditJob `websitePath` is updated.

After generation, you have buttons:

- **Open Preview** — local Next.js dev server on port 4000 (or first free port from 4000+)
- **Manage Screenshots** — drop PNGs into placeholder slots in the manifest. Site auto-rebuilds with new images.
- **Deploy** — push to Vercel via the integrated deployer (asks for your Vercel token + project name)
- **Download zip** — full site source as a zip you can extract anywhere
- **Regenerate Website** — rebuild from scratch (preserves screenshots if you've added them)
- **Delete Website** — remove the site dir (asks for confirmation; doesn't touch the AuditJob row)

For full GreenThumb walkthrough including deploying to Vercel, see [GREENTHUMB_GUIDE.md](GREENTHUMB_GUIDE.md).

---

## Save Locally / Push to GitHub / Export Project

After your project is READY, you have several ways to get the source out of `~/.tateru-pro/data/projects/`.

### Save Locally

Copies the full project to a folder of your choice + initialises a git repo there. Use this when you want to edit the code in VS Code / Android Studio / your editor of choice.

1. Pipeline page → **Save Locally** button
2. Pick a destination folder (modal opens; doesn't have to exist — Tateru creates it)
3. Tateru copies all files, runs `git init`, makes an initial commit
4. The destination becomes your "working copy" — edit there, run `flutter run` from there, etc.

Note: future Tateru pipeline runs (refinement, rebuild) still happen against `~/.tateru-pro/data/projects/<slug>/`. The save-local copy is yours to do whatever you want with — Tateru doesn't sync changes back.

### Push to GitHub

1. Pipeline page → **Push to GitHub** button
2. Modal asks for:
   - Repo name (defaults to your project slug)
   - Private / Public (defaults to Private)
   - GitHub Personal Access Token with `repo` scope (Settings → Developer Settings → Tokens at github.com)
3. Click **Push** — Tateru creates the repo via GitHub API, pushes the source, returns the URL
4. Subsequent pushes use **Push Again** (force-pushes updates)

Tateru auto-injects a `.gitignore` that excludes APK builds, .gradle cache, .dart_tool, build/, etc. — so your repo stays clean.

### Export Project (.tateru-project archive)

For moving a project to another Tateru install (Mac → Linux, work → home, etc.):

1. Pipeline page → **Export Project** button (top-right)
2. Modal lets you toggle:
   - Source files (always on; required)
   - Agent logs (default on — useful for debugging)
   - Audit history (default on)
   - Refinement history (default on)
3. Click **Export** → save the `.tateru-project` zip wherever
4. To import: on the other machine, sidebar → Import Project → drop the zip

The archive does NOT include API keys, license JWT, or any other secrets.

---

## Analytics

Sidebar → **Analytics** → page shows your local build history.

### All-time stats (top row)

5 cards:

- **Total Builds** — count of READY projects
- **Total Spend** — sum of all per-project costs (BYOK — what you actually paid your AI providers)
- **Total Build Time** — cumulative pipeline runtime
- **Total Tokens** — sum of input + output tokens across all builds
- **Total Files** — total file count across all generated projects

### Weekly / Monthly toggle table

Below the stats, a toggle picks aggregate granularity:

- **Weekly** — rolling 8-week chart of builds + spend per week
- **Monthly** — rolling 12-month chart of builds + spend per month

### Per-build detail table

Below the chart, every individual build with:
- Project name (clickable → Pipeline page)
- Status
- Started at
- Duration
- Cost
- Tokens
- File count

Sortable by any column.

### Cloud panel (replaced for Pro plan)

If you're on Trial / Starter / Maker, a "Cloud Telemetry" panel shows aggregate stats from Tateru's cloud (your build counts vs other testers, etc.). On **Pro Annual**, this panel is hidden and replaced with an info card: *"Pro plan — Private Build Mode active. No telemetry sent to Tateru's cloud."*

---

## Settings — every panel explained

Sidebar → gear icon (bottom). The Settings page is one long scrollable form with sections in this order. Skip to a section using your browser's Find (Ctrl+F).

For every-field detail, see [SETTINGS_REFERENCE.md](SETTINGS_REFERENCE.md). Below is the orientation overview.

### Account

- Your registered email + tier badge
- **Sign Out** button
- **Manage Billing** button (opens Stripe customer portal in your browser — manage subscription, update card, view invoices)
- **Upgrade Plan** button (opens UpgradeModal — pick Starter / Maker / Pro Annual; redirects to Stripe checkout)

### AI Providers

For each of 6 providers (Anthropic, OpenAI, Google, Moonshot, DeepSeek, Ollama Cloud):

- **Status indicator** — ✅ Configured (key set + last test passed) / ❌ Not configured / ⚠️ Test failed
- **API Key** field (paste key — masked after save)
- **Save** button — writes to `~/.tateru-pro/data/.env` (machine-local; never sent to Tateru's cloud)
- **Test Connection** button — calls the provider's "list models" endpoint to verify
- **Delete** button — removes the saved key (replaces with empty string in .env)

Anthropic + OpenAI are required for the default Balanced preset. Others are only needed if you switch presets or pick non-default models per agent.

### Build Model Config

The **per-agent model selection** for the build pipeline. Two modes:

**Preset mode** (default) — pick one of 5 presets:

- **Budget** — Haiku across the board. Cheapest, fastest, lower quality on complex apps. Good for prototyping.
- **Balanced** (recommended) — Sonnet on the load-bearing agents (Bob, Doc-Tor, Build Architect, Agent Orange, Feature Auditor), Haiku on lighter ones (Distiller, Thinker Bell, DocSmith, Test Generator). DALL-E for icons.
- **Premium** — Opus across the board. Highest quality, highest cost. For mission-critical builds.
- **DeepSeek Hybrid** — DeepSeek-Chat on analysis agents, Sonnet on code-gen. Cost-saver while keeping code quality.
- **Hybrid Cloud + qwen3** — Ollama Cloud's qwen3 on analysis, Sonnet on code-gen. Requires Ollama Cloud subscription.

**Custom mode** — pick a model individually for each agent. Toggle via the "Customize per agent" link below the preset cards. The customizer shows a row per agent: Distill / Architect / Docs / Build / Icons / Post Docs / Review / Test / Audit. For each, a dropdown of all available models from your configured providers. Whatever you set is used for that agent on every future build.

### Audit Model

Single dropdown — picks the model used for the 5 GreenThumb audit agents. 5 curated cards:

- **Sonnet 4.6** (recommended default — flagged Recommended)
- **Opus 4.6** (Best Quality)
- **GPT-4o** (OpenAI)
- **GPT-4o Mini** (Cheapest)
- **Haiku 4.5** (Not Recommended — flagged with explicit warning, was previously the default but drifted to producing markdown prose instead of JSON; mod 9.32.4 flipped the default)

### SDK Paths

For each SDK Tateru depends on (Flutter / Java / Android / Xcode (Mac only) / CocoaPods (Mac only)):

- **Status** — ✅ Detected at <path> + version, OR ❌ Not detected, OR ⚠️ Detected but old version
- **Override path** field — paste a custom path if auto-detection picks the wrong install
- **Save & Re-detect** button
- **Install guide** link → opens the SDK's install docs in your browser

If you change a path, Tateru also persists it as an env var (`FLUTTER_PATH`, `JAVA_HOME`, `ANDROID_HOME`) in `~/.tateru-pro/data/.env` so future build agents pick it up automatically (mod 10.122).

### Telegram Notifications

Configure Tateru to send build status notifications to a Telegram chat. Requires a Telegram bot.

**Setup:**

1. In Telegram, message [@BotFather](https://t.me/BotFather) → `/newbot` → follow prompts → get a bot token
2. Message your new bot once (so it can DM you back) → message [@userinfobot](https://t.me/userinfobot) → it replies with your Chat ID
3. In Tateru: paste both into Settings → Telegram Notifications
4. Click **Save** → **Send Test Message** → verify you got the message

**Toggles:**

- **Master Enable** — gates everything below; turn off to silence Tateru completely
- **Notify on Spec Ready** — pause pipeline after Doc-Tor, send spec summary + Approve/Reject buttons. Approve continues pipeline; Reject stops it.
- **Notify on Build Complete** — message when APK builds successfully
- **Notify on Build Failed** — message on any pipeline or APK failure
- **Approval-gate timeout** (slider, 30–3600 sec, default 600) — if you don't reply within N seconds, what should happen?
  - **Auto-reject** (default) — pipeline stops
  - **Auto-approve + auto-build APK** — pipeline continues + APK build runs without you

### Build Learnings

Manage the local-only learnings collected from your Diagnose+fix cycles.

- **Status row** — count of local rules + cloud-ready indicator
- **Share with cloud** toggle — opt-in to send your validated learnings to Tateru's cloud (helps train a better Diagnose for everyone). Paired toggle: disabling share also disables receive (prevents free-riding).
- **Local rules list** — every rule you've saved, click to expand body
- **Per-rule Delete** button — remove a rule from your local DB

For Pro Annual users, the share toggle is hidden (Private Build Mode = no telemetry). A "Manual pull" button lets Pro users still receive validated rules from cloud on demand.

### System Info

Read-only diagnostic info about your machine:

- **Disk space** — free / total on the partition where Tateru writes (`~/.tateru-pro/data/projects/`)
- **Output APKs partition** (if different) — separate readout for output_apps/
- Threshold colour-coded: green (>5GB free), amber (1–5GB), red (<1GB)
- **Refresh** button to re-query

### Diagnostics

Tools for sending Tateru bug reports to support:

- **Verbose Logging** toggle — when ON, Tateru writes detailed agent traces to a support log
- **Download Support Logs** — bundles the support log + recent agent activity into a zip you can attach to a support email
- **Email Support** — opens your email client with a prefilled support@tateru.app email

### About

- App version (e.g. v1.0.0-beta.9.32.13)
- Build date
- Links: GitHub repo / Privacy Policy / Terms of Use / Documentation

---

## Support — Send Feedback, Ask Bob, docs

### Send Feedback

Sidebar → Send Feedback → opens a form for bug reports / feature requests / questions / other.

**Fields:**

- **Type** (button group): Bug / Feature / Question / Other
- **Title** (required, max 140 chars) — short summary
- **Details** (required, multi-line) — describe what happened, what you expected, what you tried
- **Contact email** (optional — defaults to your registered email) — so we can reply
- **Include diagnostic context** checkbox (default ON) — appends app version, OS, browser, account tier to the submission. Helps us reproduce bugs faster.

Click **Send feedback** → submission goes to two places in parallel:

1. **Formspree** → forwards to support@tateru.app email inbox (primary path)
2. **Tateru's cloud admin queue** → admin can triage at `https://api.tateru.app/admin/feedback`

If your feedback gets resolved or dismissed, you receive an email back letting you know — including (when applicable) which Tateru release shipped the fix as a clickable GitHub link.

### Ask Bob

Sidebar → Ask Bob → opens a chat-style page where you can ask Bob anything about Tateru.

Bob is GPT-4o-mini powered and trained on this manual + the Quick Start + the FAQ + every release note + the Settings reference + troubleshooting guides. Ask things like:

- "How do I install on Windows?"
- "What does the Refinement Agent do?"
- "What's new in 9.32.13?"
- "How do I deploy a marketing site to Vercel?"
- "Why is my APK build failing with 'cannot find symbol Registrar'?"

Bob streams responses (you see text appear word-by-word) and supports multi-turn conversation (it remembers the last 10 messages).

If Bob can't answer your question, click **This didn't help — send feedback** at the bottom of the chat → opens Send Feedback prefilled with the conversation.

Bob queries are FREE to you — Tateru pays the OpenAI cost (~$0.0005 per question). We log your questions (with userId for Pro+ tiers, anonymous for Trial/Starter) so we can see what users actually struggle with.

### Quick Start

Sidebar → Quick Start → renders [QUICK_START.md](QUICK_START.md) in-app. Same content as on our website + bundled in the binary. Three states:

- 🟢 **Live** — fetched fresh from the public release repo (you're online + the GitHub mirror is up)
- 🔵 **Bundled** — fetched the bundled copy (public mirror not populated yet for this version)
- 🟡 **Bundled (offline)** — couldn't reach the public mirror; serving the bundled copy

Each doc page has a **Print / Save PDF** button that opens your browser's native print dialog with paper-friendly styling.

### User Manuals

Sidebar → User Manuals → renders this manual in-app (same hybrid live-fetch + bundled fallback).

### FAQ

Sidebar → FAQ → renders [FAQ.md](FAQ.md) in-app.

---

## Privacy & data — what stays local, what leaves your machine

**Stays on your machine (never sent anywhere):**

- Your project source code, file contents, generated APKs
- Your AI API keys (stored in OS keychain — macOS Keychain / GNOME Keyring / Windows Credential Manager — never in plaintext)
- Your app ideas, briefs, feature lists, descriptions
- Your screenshots (Clone-from-screenshots calls OpenAI directly from your machine using your key, but Tateru never sees the images)
- Your Telegram bot token + Chat ID

**Sent to Tateru's cloud (per tier):**

| Data | Trial / Starter / Maker | Pro Annual |
|---|---|---|
| Auth (login + session) | ✅ | ✅ |
| License validation + Stripe events | ✅ | ✅ |
| Anonymous build telemetry (counts, agent timings, error categories) | ✅ | ❌ Private Build Mode |
| Build Learnings (when you opt in) | ✅ (paired toggle) | ❌ |
| Ask Bob queries (with userId for analytics) | userId logged | userId logged |
| Send Feedback submissions | ✅ | ✅ |

**Sent to your own AI providers (not to Tateru):**

- Every agent prompt + response (this is the BYOK part — Tateru orchestrates, you pay)
- Project briefs, code, build context — flows to Anthropic / OpenAI / etc. per their privacy policies (which you accepted when you signed up with them)

For full policy text see [PRIVACY_POLICY.md](https://github.com/ushanboe/tateru-pro-releases/blob/main/docs/PRIVACY_POLICY.md).

---

## Plans, billing, and the trial

### The trial

Every new account gets a **14-day free trial** with full Tateru access. No card required upfront. After day 14, the trial expires and the build pipeline blocks until you upgrade.

Trial-ending warning emails fire at day 12 (2 days before).

### Tiers

| Tier | Price | Period | $/mo | Privacy |
|---|---|---|---|---|
| **Trial** | Free | 14 days | — | Telemetry on |
| **Starter** | $19 | Monthly | $19 | Telemetry on |
| **Maker** | $72 | 6 months | $12 | Telemetry on |
| **Pro Annual** | $120 | 12 months | $10 | **Private Build Mode included** |

**All paid tiers have IDENTICAL features** — differentiation is commitment + privacy:

- Longer commitments = lower per-month price
- Pro Annual = telemetry off (Private Build Mode)

There is no per-build fee, no marketplace cut, no royalty on apps you ship. Tateru is a flat subscription + your AI provider costs.

### What "Private Build Mode" means

On Pro Annual:

- No anonymous build telemetry sent to Tateru's cloud
- No Build Learnings shared (manual pull button to receive validated rules from cloud is still available)
- "Cloud Telemetry" Analytics panel hidden — replaced with explicit Pro plan info card
- All other features identical

### Cancellation

Cancel any time via Settings → Manage Billing (Stripe customer portal). Cancellation takes effect at the end of your current billing period.

When a subscription ends:

- Status flips to EXPIRED
- The build pipeline blocks (you can't start new builds)
- Everything else keeps working — Settings, past projects in My Apps, Workbench browse + AI Chat, exports, docs

Your local projects, code, and APKs are yours — they stay on your machine. You can re-subscribe later and pick up where you left off.

---

## Where to get help

In rough order of speed-to-answer:

1. **Ask Bob** (sidebar) — Bob has read this manual + every release note + the FAQ. Most user-facing questions get answered instantly. Free.
2. **FAQ** (sidebar) — common questions about cost, BYOK, app types, known limitations
3. **This User Manual** (sidebar → User Manuals) — what you're reading
4. **Send Feedback** (sidebar) — bug reports + feature requests + questions. Goes to support@tateru.app + Tateru's admin queue. Reply within 24 hours during beta.
5. **support@tateru.app** — direct email if you'd rather not use the in-app form
6. **GitHub Discussions** — community Q&A at the public release repo (when we launch one — currently early access only)

---

*This manual is a living document. Last updated for Tateru Pro v1.0.0-beta.9.32.13 on 2026-05-11. The latest version always lives at the [public release repo's docs/USER_MANUAL.md](https://github.com/ushanboe/tateru-pro-releases/blob/main/docs/USER_MANUAL.md).*
