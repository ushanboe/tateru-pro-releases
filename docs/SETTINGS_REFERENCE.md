---
**App:** Tateru Pro
**Version:** 1.0.0-beta.9.32.13
**Owner:** KangaBlue.au
**Contact:** support@tateru.app
**Last updated:** 2026-05-11
---

# Settings Reference

Every field in Tateru's Settings page, what it does, what it affects, and what to do when it's not behaving the way you expect.

The Settings page is one long scrollable form. Sections appear in this order in the UI:

1. [Account](#account)
2. [AI Providers](#ai-providers)
3. [Build Model Config](#build-model-config)
4. [Audit Model](#audit-model)
5. [SDK Paths](#sdk-paths)
6. [Telegram Notifications](#telegram-notifications)
7. [Build Learnings](#build-learnings)
8. [System Info](#system-info)
9. [Diagnostics](#diagnostics)
10. [About](#about)

---

## Account

Identity + billing information for your Tateru Pro account.

### Fields

| Field | What it shows / does |
|---|---|
| **Email** | Your registered email (read-only — change via Manage Billing or contact support) |
| **Name** | Your display name (auto-filled from registration) |
| **Tier** | Badge: Trial / Starter / Maker / Pro |
| **License status** | ACTIVE / EXPIRED / SUSPENDED / CANCELLED |
| **Trial expires** (Trial only) | Date when trial ends; trial-ending email fires 2 days before |
| **Current period end** (paid only) | Stripe billing period end |
| **Billing plan** (paid only) | monthly / six_month / annual |

### Buttons

| Button | What it does |
|---|---|
| **Sign Out** | Clears your local session token. You're returned to the Login screen. Your projects + local data stay on disk. |
| **Manage Billing** | Opens Stripe customer portal in your default browser. Update card, view invoices, cancel subscription. |
| **Upgrade Plan** | Opens UpgradeModal — pick Starter / Maker / Pro Annual; redirects to Stripe checkout. |
| **Refresh** | Re-fetches your tier + license info from Tateru's cloud. Useful after an upgrade if the new tier hasn't auto-detected yet. |

### What changes when your tier changes

- **Trial → Paid** — pipeline blocks lift immediately
- **Paid → Pro Annual** — Private Build Mode kicks in: anonymous build telemetry stops, Build Learnings share toggle hides
- **Any → Cancelled / Expired** — pipeline blocks (you can't start new builds); everything else (Settings, past projects, Workbench browse, exports, docs) keeps working

### Common questions

- **"My tier is wrong after upgrade"** → click Refresh. Or sign out + sign back in. Cloud auth refreshes auth-on-window-focus + on a 30s throttle, so usually picks up automatically.
- **"My subscription cancelled but I want to come back"** → Sign in, click Upgrade Plan. Pick a tier. Your old projects are still in your local DB.

---

## AI Providers

API keys for the LLM providers Tateru uses. Each provider has its own card.

### Per-provider card

For each of 6 providers (Anthropic / OpenAI / Google / Moonshot / DeepSeek / Ollama Cloud):

| Field / button | What it does |
|---|---|
| **Status indicator** (top-right of card) | ✅ Configured (key set + last test passed) / ❌ Not configured (no key) / ⚠️ Test failed (key set but provider rejected it) |
| **API Key** field | Paste a key from the provider. Masked after save (shows first 6 + last 4 chars, the rest as bullets). |
| **Save** button | Writes the key to `~/.tateru-pro/data/.env` (machine-local; never sent to Tateru's cloud). |
| **Test Connection** button | Calls the provider's "list models" endpoint to verify the key. Updates the status indicator. |
| **Delete** button | Removes the saved key (replaces with empty string in .env). Status flips to ❌ Not configured. |

### Where to get each key

| Provider | Get a key |
|---|---|
| **Anthropic** (Claude) | [console.anthropic.com](https://console.anthropic.com) → API Keys → Create Key |
| **OpenAI** (GPT, DALL-E) | [platform.openai.com](https://platform.openai.com) → API keys → Create new secret key |
| **Google** (Gemini) | [aistudio.google.com](https://aistudio.google.com) → Get API Key |
| **Moonshot** (Kimi) | [platform.moonshot.cn](https://platform.moonshot.cn) (Chinese site; English available) |
| **DeepSeek** | [platform.deepseek.com](https://platform.deepseek.com) → API Keys |
| **Ollama Cloud** | [ollama.com/cloud](https://ollama.com/cloud) → Subscribe → Get API Key |

### Which providers do I actually need?

For the default Balanced preset:

- **Required:** Anthropic + OpenAI
- **Optional:** Google / Moonshot / DeepSeek / Ollama Cloud (only if you switch to a preset that uses them OR pick non-default models per agent)

If you're a Pro Annual user: same — Tateru is BYOK regardless of tier.

### Privacy

API keys are stored in `~/.tateru-pro/data/.env` as plaintext (mod 10.32+). They never:
- Leave your machine
- Get sent to Tateru's cloud
- Get included in `.tateru-project` exports
- Get written to logs

**Pre-9.25 caveat:** earlier beta versions (pre-mod 10.48) accidentally bundled real test keys in the binary. Those keys have been rotated. If you installed before beta.9.25 and never explicitly Saved your own keys, **delete + re-save them now** to overwrite the leaked ones cached in your userData.

---

## Build Model Config

Pick which AI model runs each agent in the build pipeline. This is where you tune the cost/quality/speed trade-off.

### Two modes

#### Mode A — Preset (default)

Pick one of 5 preset cards. Each card shows: cost-per-build estimate, build-time estimate, quality rating, when to use it.

| Preset | Cost / build | Build time | Quality | Best for |
|---|---|---|---|---|
| **Budget** | ~$1–$4 | 20–40 min | Basic | Prototyping ideas |
| **Balanced** (recommended) | ~$6–$20 | 30–60 min | High | Most builds |
| **Premium** | ~$20–$50 | 30–60 min | Best | Complex apps, critical builds |
| **DeepSeek Hybrid** | ~$4–$10 | 30–60 min | High | Cost-saver — DeepSeek on analysis, Sonnet on code-gen |
| **Hybrid Cloud + qwen3** | ~$2–$6 | 30–60 min | High | Requires Ollama Cloud subscription |

Click a preset → all 9 agents are set to that preset's choices. Changes take effect immediately for the next build.

#### Mode B — Customize per agent

Click "Customize per agent" link below the presets → a 9-row table appears. For each agent (Distill / Architect / Docs / Build / Icons / Post Docs / Review / Test / Audit):

- **Agent name** column (fixed-width)
- **Phase** column (e.g. "DISTILLATION", "BUILD")
- **Model** dropdown — every model from your configured providers + recommended star indicator on safe defaults

Pick whatever you want for each. Custom configs are saved per-project (each new project starts from your current preset choice but can be overridden).

### What each agent uses the model for

| Agent | Model affects | Recommended class |
|---|---|---|
| **Distiller** | Spec compression — short summaries | Cheap (Haiku is fine) |
| **Thinker Bell** | Research — finds similar apps + Flutter packages | Cheap to medium |
| **Build Architect** | Combines all sources, classifies feature buildability | Medium to high (Sonnet) |
| **Doc-Tor** | Writes the full build spec — structured JSON, 30K+ tokens output | **HIGH (Sonnet recommended)** — cheap models often produce malformed JSON or miss screens |
| **Bob the Builder** | Generates the actual Flutter code | **HIGH (Sonnet recommended)** — code quality is critical here |
| **Icon Generator** | Image generation (DALL-E 3) | Fixed at gpt-image-1 — no choice (image generation is a different API surface) |
| **DocSmith** | Writes user-facing docs | Cheap to medium (Haiku is fine for docs) |
| **Agent Orange** | Reads + fixes code in 1–7 review cycles | **HIGH (Sonnet recommended)** — most expensive agent; Haiku produces lower-quality fixes that need more cycles |
| **Test Generator** | Writes integration tests | Cheap to medium |
| **Feature Auditor** | Verifies every feature is wired | Medium to high |

### Common customizations

- **"I want cheaper but don't want to risk Bob"** → Balanced preset, then per-agent customize Distiller / Thinker Bell / DocSmith / Test Generator → switch to Haiku. Saves ~$1-2 per build with no code-quality risk.
- **"I want best possible code quality regardless of cost"** → Premium preset (Opus across the board). Or Custom: Sonnet on Bob, Opus on Agent Orange + Doc-Tor.
- **"I want to use Ollama for privacy"** → Hybrid Cloud + qwen3 preset. Or Custom: Ollama on Distiller / Thinker Bell / DocSmith / Test Generator (the cheap-easy agents), Sonnet on the rest.

### Restart-to-apply

Settings changes take effect on the **next build start**. In-flight builds use whatever was configured when they started.

---

## Audit Model

Single dropdown — picks the model used for the 5 GreenThumb audit agents (App Summary / Doc Audit / Legal Audit / Icon Agent / Web Presence).

### 5 curated cards

| Card | When to pick |
|---|---|
| **Sonnet 4.6** (recommended default — flagged Recommended) | Most audits. Good balance of cost + accuracy. |
| **Opus 4.6** (Best Quality) | When the audit is critical (e.g. before pushing to Play Store). |
| **GPT-4o** | Alternative to Sonnet — cheaper sometimes, comparable accuracy. |
| **GPT-4o Mini** (Cheapest) | Quick iteration on the audit during development. ~$0.05 per audit. |
| **Haiku 4.5** (Not Recommended — flagged with explicit warning) | Was the default pre-9.32.4 but drifted to producing markdown prose instead of JSON. Default flipped to Sonnet in mod 10.95. Use only if you have a specific reason. |

### Provider-key gating

Cards for providers you haven't configured (no API key in AI Providers section) appear greyed out with a "Configure {provider} key first" tooltip. Click the card → takes you up to AI Providers section.

### Cost per audit

| Card | Typical cost per full 4-step audit |
|---|---|
| Sonnet 4.6 | $0.10–$0.50 |
| Opus 4.6 | $1.00–$3.00 |
| GPT-4o | $0.20–$0.80 |
| GPT-4o Mini | $0.02–$0.10 |
| Haiku 4.5 | $0.05–$0.20 |

---

## SDK Paths

Tateru depends on several external SDKs to build apps. This section auto-detects them and lets you override paths if auto-detection picks the wrong install.

### Per-SDK card

For each of 5 SDKs (Flutter / Java / Android / Xcode (Mac only) / CocoaPods (Mac only)):

| Field / button | What it does |
|---|---|
| **Status** | ✅ Detected at <path> + version, OR ❌ Not detected, OR ⚠️ Detected but old version |
| **Override path** | Paste a custom path if auto-detection picks the wrong install |
| **Save & Re-detect** | Saves the override + re-runs detection (fires `flutter --version` etc.) |
| **Install guide** link | Opens the SDK's install docs in your browser |

### Auto-detection paths per OS

#### Flutter

- `$FLUTTER_PATH` env var (if set)
- `flutter` on PATH
- Linux: `~/flutter/bin`, `~/development/flutter/bin`, `~/snap/bin`, `~/.local/bin`, `~/.fvm/default/bin`, `/opt/flutter/bin`, `/usr/local/bin`
- Mac: same as Linux (Flutter is typically installed manually)
- Windows: `C:\src\flutter\bin\flutter.bat`, `C:\flutter\bin\flutter.bat`, `C:\dev\flutter\bin\flutter.bat`, `%USERPROFILE%\flutter\bin\flutter.bat`, `%USERPROFILE%\development\flutter\bin\flutter.bat`, `%LOCALAPPDATA%\flutter\bin\flutter.bat`, `%LOCALAPPDATA%\Pub\Cache\bin\flutter.bat`

If detection succeeds via fallback path AND `FLUTTER_PATH` env var is empty, mod 10.122 (9.32.13+) auto-saves the discovered path to `~/.tateru-pro/data/.env`. This guarantees Bob's spawn at runtime gets the absolute path instead of falling back to bare `flutter` (which fails on Windows when cmd.exe's inherited PATH doesn't include the Flutter dir).

#### Java JDK

- `$JAVA_HOME` env var (if set)
- Bundled JDKs in: Android Studio → IntelliJ → JetBrains Toolbox (most Android devs have THIS Java, never installed standalone)
- Standalone installs: Adoptium / Oracle / Microsoft / Zulu / Amazon Corretto
- `java` on PATH

#### Android SDK

- `$ANDROID_HOME` env var (if set)
- `$ANDROID_SDK_ROOT` env var (legacy, fallback)
- Linux: `~/Android/Sdk`
- Mac: `~/Library/Android/sdk`
- Windows: `%LOCALAPPDATA%\Android\Sdk` (Android Studio default)

#### Xcode (Mac only)

- `xcrun` on PATH (means Command Line Tools or full Xcode installed)
- Returns the Xcode version + path

#### CocoaPods (Mac only)

- `pod` on PATH
- Tateru waits up to **90 seconds** for `pod --version` (mod 10.28) — first invocation after `brew install cocoapods` clones the specs repo (~30-60s) and was firing a misleading "CocoaPods not on PATH" timeout pre-mod-10.28

### Manual override

Examples of when to use Override path:

- You have multiple Flutter installs and Tateru picked the wrong one
- Your Flutter is in a non-standard location (e.g. `/usr/local/Cellar/flutter/...` from Homebrew)
- Your Android SDK is on a different drive on Windows (`D:\Android\Sdk`)

After Save & Re-detect, the path is also persisted as the corresponding env var (`FLUTTER_PATH` / `JAVA_HOME` / `ANDROID_HOME`) so future build spawns pick it up.

---

## Telegram Notifications

Tateru can send build status notifications to a Telegram chat. Useful when builds run on your desktop and you're away from the screen.

### Setup (one-time)

1. In Telegram, message [@BotFather](https://t.me/BotFather) → `/newbot` → follow prompts
2. BotFather replies with your **bot token** (looks like `123456789:AAAAAA...`)
3. Message your new bot once (so it can DM you back)
4. Message [@userinfobot](https://t.me/userinfobot) — it replies with your **Chat ID** (a 9-10 digit number)

### Fields

| Field | What it does |
|---|---|
| **Bot Token** | Paste from BotFather. Stored locally in `.env` as `TELEGRAM_BOT_TOKEN`. |
| **Chat ID** | Your Telegram user ID (or a group ID for shared notifications). |
| **Save** | Writes both to `.env`. |
| **Send Test Message** | Posts "Tateru Pro is connected ✓" to the chat. Verifies setup. |

### Toggles

- **Master Enable** — gates everything below; turn off to silence Tateru completely without unconfiguring
- **Notify on Spec Ready** — when ON, the pipeline pauses after Doc-Tor and sends you the spec summary + Approve/Reject inline buttons. Approve continues the pipeline; Reject stops it. Useful when you want to review the spec before the expensive Bob phase runs.
- **Notify on Build Complete** — message when APK builds successfully
- **Notify on Build Failed** — message on any pipeline or APK failure

### Approval-gate timeout

If "Notify on Spec Ready" is ON and you don't reply within N seconds, what should happen?

- **Slider** — 30 to 3600 seconds (30s minimum, 1 hour max). Default 600s (10 min).
- **Auto-action** dropdown:
  - **Auto-reject** (default) — pipeline stops on timeout
  - **Auto-approve + auto-build APK** — pipeline continues + APK build runs without you (use only when you've configured Tateru with verified billing limits)

### Privacy

The bot token + Chat ID never leave your machine — Tateru talks to Telegram's API directly using your token. No proxy through Tateru's cloud.

---

## Build Learnings

Manage the local-only learnings collected from your Diagnose+fix cycles. The Build Learnings program is Tateru's self-improving feedback loop — each fix you save makes future builds smarter.

### Status row

- **Total local rules** — count of rules in `~/.tateru-pro/data/local-mistakes.md`
- **Cloud-ready indicator** — ✅ if `SHARE_BUILD_LEARNINGS=true` in your .env, ❌ if false (paired toggle below)

### Share with cloud (toggle)

Default OFF. When ON:

- After saving a fix to local learnings (via Diagnose modal), the rule is also queued for upload to Tateru's cloud admin queue
- Upload happens 48 hours later (debounce window so you can review/delete first)
- Cloud maintainer reviews, approves, or rejects → if approved, the rule eventually ships in the next bundled MISTAKES.md release for everyone

The toggle is **paired** — disabling share also disables receive (prevents free-riding off other contributors).

### Pro Annual variation

For Pro Annual users:

- The share toggle is **hidden** — Pro = Private Build Mode = no telemetry contributions
- A **"Manual pull"** button replaces the toggle — fetches validated rules from cloud on demand (so Pro users still get the benefit of community-contributed rules without contributing themselves)

### Local rules list

Below the toggle, every local rule:

- **L<N>** — auto-numbered (L1, L2, L3...)
- **Title** — short summary
- **Saved** — timestamp + which build target the rule applies to (apk / ios / macos)
- **Body** (collapsible) — full rule with diagnostic signature + fix
- **Delete** button — removes from local-mistakes.md AND from cloud queue (if shared)

Rules are loaded into Bob's prompt on every build — so each rule actively prevents the matched bug from reoccurring in your future projects.

---

## System Info

Read-only diagnostic info about your machine. Helps you decide what to clean up if disk is tight.

### Disk space cards

For the partitions where Tateru writes:

- **Projects partition** — `~/.tateru-pro/data/projects/` filesystem
- **Output APKs partition** — `~/.tateru-pro/data/output_apps/` filesystem (often the same partition, but split out for users with custom configs)

For each:

- Free GB / Total GB
- Threshold colour: **green** (>5GB free), **amber** (1–5GB), **red** (<1GB)
- Recommended budget: ~1GB headroom per build, 5GB+ for comfortable repeated use

### Refresh button

Re-queries the disk via `fs.statfs` (Node 19+ cross-platform — mod 10.121).

### What to do at each threshold

- **Green** — you're fine. No action needed.
- **Amber** — get more headroom. Common cleanups:
  - Old projects under `~/.tateru-pro/data/projects/<slug>/` — delete from My Apps if you don't need them
  - Pub cache: `flutter pub cache repair` (deletes broken packages) or `rm -rf ~/.pub-cache` (nuclear — re-downloads on next build)
  - Gradle cache: `rm -rf ~/.gradle/caches/`
- **Red** — Tateru builds may fail mid-run with EBADF / ENOSPC. Free space before starting any new builds.

---

## Diagnostics

Tools for sending Tateru bug reports to support.

### Verbose Logging toggle

When ON, Tateru writes detailed agent traces to a support log at `~/.tateru-pro/data/support.log`. This is more verbose than the standard logs (includes per-LLM-call request/response previews, file write events, etc.).

Turn ON only when you're trying to reproduce a bug — verbose logs grow fast (~50MB/hour during active builds).

### Buttons

- **Download Support Logs** — bundles the support log + recent agent activity into a zip (`tateru-support-bundle.txt`) you can attach to a support email
- **Email Support** — opens your default email client with a prefilled support@tateru.app email (subject: "Tateru Pro Beta — Support Request") + body asking you to attach the support bundle

### What's in the support bundle

- The support log (last 24 hours)
- Recent agent activity logs (last 10 builds)
- App version + OS info
- Settings snapshot (with API keys masked)
- Recent error events from the local DB

What's NOT in it:

- Your project source code
- Your API keys (masked or omitted)
- Your spec content
- Anything from `~/.tateru-pro/data/projects/`

---

## About

Identity card for the running version of Tateru.

| Field | What it shows |
|---|---|
| **App version** | Build-time version, e.g. `v1.0.0-beta.9.32.13` (mod 10.88 — injected at Vite build time from package.json) |
| **Build date** | When this binary was packaged |
| **Platform** | Detected host platform (linux / darwin / win32) |

### Links

- **GitHub repo** → public release repo on GitHub
- **Privacy Policy** → in-app or website
- **Terms of Use** → in-app or website
- **Documentation** → public release repo's docs/ mirror
- **Contact** → mailto:support@tateru.app

---

*See also: [USER_MANUAL.md](USER_MANUAL.md), [QUICK_START.md](QUICK_START.md), [TROUBLESHOOTING.md](TROUBLESHOOTING.md).*
