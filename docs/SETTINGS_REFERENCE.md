---
**App:** Tateru Pro
**Version:** 1.0.0-beta.9.34.15
**Owner:** KangaBlue.au
**Contact:** support@tateru.app
**Last updated:** 2026-06-08
---

# Settings Reference

Every field in Tateru's Settings page, what it does, what it affects, and what to do when it's not behaving the way you expect.

The Settings page is one long scrollable form. Sections appear in this order in the UI:

1. [Account](#account)
2. [AI Providers](#ai-providers)
3. [Build Model Config](#build-model-config)
4. [Audit Model](#audit-model)
5. [GreenThumb Website Model](#greenthumb-website-model)
6. [Refinement Agent Model](#refinement-agent-model)
7. [SDK Paths](#sdk-paths)
8. [Apple Developer Team ID](#apple-developer-team-id)
9. [Auto-Refine build failures (experimental)](#auto-refine-build-failures-experimental)
10. [Telegram Notifications](#telegram-notifications)
11. [Build Learnings](#build-learnings)
12. [Cloud Sauce indicator](#cloud-sauce-indicator)
13. [Power user mode](#power-user-mode)
14. [Privacy & Reset](#privacy--reset)
15. [System Info](#system-info)
16. [Diagnostics](#diagnostics)
17. [About](#about)

### Removed / disabled in this version

- **Themed builds toggle** — *removed.* Look & feel (vibe → colour scheme → font) is now chosen in **New Project**, not in Settings.
- **Trendcast (Decide / Predict)** — *disabled by default.* The prediction sidecar no longer spawns and the Decide/Predict UI is hidden. Re-enable with `TRENDCAST_ENABLED=true`.

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

For each provider (Anthropic / OpenAI / Google / Moonshot / Z.AI / DeepSeek / Ollama Cloud):

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
| **Z.AI** (GLM-4.6) | [z.ai](https://z.ai) → API platform → API Keys. Stored as `Z_AI_API_KEY`. Powers the **GLM-4.6** model — a much cheaper Bob alternative (~$1.90/build vs ~$2.50 on Sonnet). |
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

The presets are split into **two rows** — one per pipeline:

- **Brief pipeline** — the standard AI Spec / Discover / Manual / JSON / Clone build flow (Bob the Builder generates code from a spec).
- **Design pipeline** — the design-driven flow (DesignBob builds against a chosen screen design).

Each preset is **named after the model Bob runs**, since Bob is the single biggest driver of build cost and quality:

| Preset | Bob runs on | Notes |
|---|---|---|
| **Bob: Anthropic Sonnet** (default) | Claude Sonnet | Recommended — best balance of cost + quality for most builds |
| **Bob: Z.ai GLM-4.6** | GLM-4.6 (Z.AI) | Cheapest — ~$1.90/build. Requires `Z_AI_API_KEY` set in AI Providers |
| **Bob: Anthropic Sonnet Pro** | Claude Sonnet | Higher-effort Sonnet pass for complex apps |
| **Bob: Anthropic Opus** | Claude Opus | Best quality, highest cost — complex/critical builds |

Each preset card shows a cost-per-build estimate, build-time estimate, quality rating, and when to use it. Click a preset → all agents are set to that preset's choices. Changes take effect immediately for the next build.

**ThinkerBell + Build Architect are pinned to Sonnet on the cheap presets** (e.g. Bob: Z.ai GLM-4.6). These two agents emit large structured JSON that smaller/cheaper models tend to truncate or malform, which breaks the rest of the pipeline — so they stay on Sonnet even when Bob is on a cheaper model.

#### Mode B — Customize per agent

Click "Customize per agent" link below the presets → a per-agent table appears. For each agent — Distiller / Thinker Bell / Build Architect / Doc-Tor / Bob the Builder / **Design Bob** / **Design Doc-Tor** / Icon Generator / DocSmith / Agent Orange / **Refinement Agent** / Test Generator / Feature Auditor:

- **Agent name** column (fixed-width)
- **Phase** column (e.g. "DISTILLATION", "BUILD")
- **Model** dropdown — every model from your configured providers (including GLM-4.6 when `Z_AI_API_KEY` is set) + recommended star indicator on safe defaults

The customizer includes the **design-pipeline agents** (Design Bob + Design Doc-Tor) and the **Refinement Agent** alongside the standard build agents. Pick whatever you want for each. Custom configs are saved per-project (each new project starts from your current preset choice but can be overridden).

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

## GreenThumb Website Model

Single dropdown — picks the model used to generate the GreenThumb marketing website (hero, features, copy, per-app chat route).

- **Default: Sonnet 4.6** — recommended for most site generations. A whitelist + post-generation validator catches any hallucinated `lucide-react` icon names regardless of model, but Sonnet rarely needs the safety net.
- Curated dropdown of the same model classes as Audit Model (Sonnet 4.6 / Opus 4.6 / GPT-4o / GPT-4o Mini / Haiku 4.5). Cheaper models are cost-attractive but more prone to hallucinated icons + off-brand copy.

Cards for providers you haven't configured (no API key in AI Providers) appear greyed out.

---

## Refinement Agent Model

Single dropdown — picks the model used by the Refinement Agent (the agent that applies "fix this / change that" instructions to a built app and the auto-Refine recovery loop).

- **Default: Sonnet 4.6** — recommended. Refinement is the user-facing recovery path, so speed-to-fix matters more than per-call cost.
- Curated dropdown (Sonnet 4.6 / Opus 4.6 / GPT-4o / GPT-4o Mini / Haiku 4.5). Some users flip this to Opus for harder multi-step root-cause fixes.

Before this picker existed, the Refinement Agent silently fell back to the default model; the explicit slot makes the choice visible and per-machine persistent.

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

## Apple Developer Team ID

**(Mac only — iOS signing.)** The Apple Developer Team ID Tateru uses to sign iOS builds for install on a real iPhone.

- **Auto-detected from the macOS keychain** on your first iOS build, so you don't have to do the Xcode "Signing & Capabilities" dance.
- This field lets you **set it explicitly** — needed if your keychain has **multiple Developer Teams** (Tateru can't guess which one), or to override the auto-detected value.
- Get your Team ID from [developer.apple.com/account](https://developer.apple.com/account) → Membership.

If left blank, Tateru auto-detects. If a single team is in your keychain, the auto-detection just works. If multiple teams are present and this field is empty, the iOS build surfaces an error listing the detected teams and pointing you here.

---

## Auto-Refine build failures (experimental)

A toggle (**default OFF**) that turns build-failure recovery into an autonomous loop. When ON, a failed build automatically runs **Diagnose → Refine → Re-build**, repeating until it recovers or hits one of your limits — then surfaces a report if it couldn't.

### Controls

| Control | What it does |
|---|---|
| **Master toggle** | Default OFF. When OFF, build failures behave as before (manual Diagnose + Refine). |
| **Max cycles** (slider) | Hard cap on how many Diagnose → Refine → Re-build cycles the loop attempts before stopping. |
| **Cost ceiling** | A spend cap (BYOK LLM cost). The loop hard-stops before a cycle that would exceed the ceiling — so it can never run away with your API spend. |
| **Pause on low confidence** | When ON, the loop halts (instead of attempting a probably-wrong fix) if Diagnose reports low confidence in its diagnosis. |

You can cancel the loop at any time. It's experimental — opt in deliberately. The cycle cap + cost ceiling + pause-on-low-confidence together bound the worst case.

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

Manage the learnings collected from your Diagnose+fix cycles. The Build Learnings program is Tateru's self-improving feedback loop — each fix you save makes future builds smarter.

### Cloud rules — ON by default

Every install now pulls the latest validated build-rules from the cloud into Bob's knowledge (not just the rules baked into the binary), so fixes reach you between Tateru releases. This is **on by default** — a "sauce line" under the version number in the sidebar + a white LED on Bob's pipeline tile show when cloud rules are live.

**Fail-safe:** if you're offline or not signed in, builds run on the bundled rules exactly like before — nothing blocks. Opt out with `CLOUD_RULES=false` in your `.env`.

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

## Cloud Sauce indicator

A small LED-style pill below the app version in the sidebar that shows whether the **latest** authoritative build rules (`MISTAKES.md` + `CURATED_PACKAGES.md`) from Tateru's cloud vault are in use.

**Hidden by default.** The pill renders nothing unless you opt in via the `CLOUD_RULES` environment flag — normal Tateru builds are unaffected.

### What it is

Bob the Builder needs a catalogue of "known anti-patterns" + "recommended packages" to write good Flutter code. Today that catalogue ships **inside the binary** (every install has it, immutable until the next Tateru release). The Cloud Sauce path pulls the same catalogue **from an authenticated cloud vault** instead, so:

- New learnings reach you between Tateru releases (typically days, not weeks)
- The catalogue stays out of the public download binary
- Pro Annual users (Private Build Mode) can still pull — telemetry stays off

This is gated by the `CLOUD_RULES` flag while we dogfood the path. Once stable across Linux/Mac/Windows it'll become the default (planned for Tateru ≥ 9.34).

### LED states

| Colour | Pill text | Meaning |
|---|---|---|
| ⚪ (hidden) | — | `CLOUD_RULES` flag is OFF (the default). Bob uses the bundled rules — byte-for-byte the current behaviour. |
| 🟡 amber | `Cloud sauce · not downloaded` + **Pull** | Flag is ON but no local cache yet. Click **Pull** to download (one-time, ~1MB; authenticated via your Tateru license). |
| 🟢 emerald | `Cloud sauce vN · latest` | Flag is ON, cache present, **and** the cloud reports your cached version matches the latest validated rules. You're current. |
| 🟠 amber | `Cloud sauce vN · update available` + **Pull** | Flag is ON, cache present, cloud has a newer version. Click **Pull** to refresh. Next build uses the updated rules. |
| 🔵 sky | `Cloud sauce vN · offline` | Flag is ON, cache present, but cloud version-check failed (offline, network blocked, or the cloud version endpoint isn't reachable). Cache still works — Bob loads from disk; we just can't confirm "latest" without a verified comparison. **Honest UX:** never claims "latest" without proof. |

The pill re-checks the cloud on **window focus**, throttled to once per 60 seconds. No background polling. The **Pull** button shows `Pulling rules…` while the request is in flight.

### How to enable (dogfood)

1. Open your user data .env file:
   - **Linux:** `~/.config/tateru-pro-plus/.env`
   - **macOS:** `~/Library/Application Support/tateru-pro-plus/.env`
   - **Windows:** `%APPDATA%/tateru-pro-plus/.env`
2. Add (or change) the line: `CLOUD_RULES=1`
3. Restart Tateru. The pill appears below the version number in the sidebar.
4. First state will be 🟡 **not downloaded**. Click **Pull** — pill flips to "Pulling rules…", then 🟢 **latest** (or 🔵 **offline** if the cloud version endpoint isn't deployed yet for your install — see Troubleshooting).

### How to disable

Remove the `CLOUD_RULES=1` line (or set `CLOUD_RULES=0`), then restart. The pill disappears and Bob falls back to bundled `MISTAKES.md` + `CURATED_PACKAGES.md`.

### Where the cache lives

`~/.tateru-pro/data/cloud-cache/` (or your `TATERU_DATA_DIR` override) contains:

- `MISTAKES.md` — pulled rule library (replaces bundled when `CLOUD_RULES=1`)
- `CURATED_PACKAGES.md` — pulled package recommendations (replaces bundled when `CLOUD_RULES=1`)
- `rules.version.json` — `{ mistakes, curated, fetchedAt }` — drives the LED state

Safe to delete the cache dir at any time. With `CLOUD_RULES=1` the pill returns to 🟡 **not downloaded**; with the flag OFF the deletion has no effect.

### Pro Annual + Private Build Mode

The pill works identically for Pro Annual users — pulling rules is **inbound** traffic (no telemetry shared), so Private Build Mode doesn't restrict it. You still benefit from the latest community-validated rules; you just don't share back yourself.

### Common questions

- **"I clicked Pull and got 🔵 offline instead of 🟢 latest"** → Cache was populated successfully (you'd see 🟡 if it had failed). The cloud's cheap version-check endpoint (`/api/v1/rules/version`) just isn't reachable from your install yet. As of the most recent dev tree, the endpoint hasn't been deployed to Railway — see Troubleshooting for details. Bob is still using the new cached rules in the meantime.
- **"Pull button does nothing"** → Check Tateru cloud auth. The pull requires a valid license JWT (same auth as the rest of the cloud). Sign out + back in if needed.
- **"I want to revert to bundled rules"** → Set `CLOUD_RULES=0` (or remove the line) + restart. The cache is left on disk but ignored.

---

## Power user mode

A toggle that enables advanced controls for users who want more direct pipeline control.

- When ON, the **"Restart from phase…"** control appears on the Pipeline page — letting you re-run the build from a chosen pipeline phase instead of only restarting the whole pipeline.
- Off by default. Turn it on if you understand the pipeline phases and want to surgically re-run part of a build.

---

## Privacy & Reset

Tools to wipe locally-stored credentials + data without losing your built apps.

- **Reset** wipes your saved **API keys** (the `.env`) and the local **database** (`tateru.db`), giving you a clean slate.
- Your **projects and built APKs** are **kept** — `projects/` and `output_apps/` are preserved.
- Use this to clear out test keys/data, or to hand a machine over without leaking credentials, while keeping your existing work.

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
