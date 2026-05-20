# Frequently Asked Questions

**App:** Tateru Pro

---

## What does Tateru Pro do?

Tateru Pro builds real, installable Android apps (and iOS / macOS, experimentally) from a description or spec. You bring your own AI key (BYOK), Tateru runs a 10-agent pipeline that writes the Flutter code, generates an icon, builds the APK, and audits the result.

---

## How much does an app cost to build?

Calibrated against real-world spend across Phase 20–22 builds (Retrowind, ClassiPod, Rewind, Hauntly).

| Build complexity | Approximate Anthropic spend (Balanced preset) | Build time |
|---|---|---|
| Tiny utility (calculator, timer) | $2–$6 | 20–30 min |
| Typical (todo app, journal, music player) | $6–$20 | 30–60 min |
| Complex (multi-screen with AI features) | $20–$50 | 60+ min |
| Refinement cycles | $1–$6 each | 5–15 min each |

Money goes to Anthropic directly via your BYOK key — Tateru doesn't take a cut.

You can lower this with the **Budget** preset (Haiku-only, ~$1–$4/build) at the cost of more refinement cycles. Or push DocTor + Bob + Agent Orange to a cheaper tier in Settings → Build Model Config.

---

## Do I have to use Anthropic? What about OpenAI / Gemini / Moonshot?

Tateru works with:
- **Anthropic** (Claude Haiku 4.5 + Sonnet 4.6) — recommended
- **OpenAI** (GPT-5 + GPT-4o-mini) — works for most agents
- **Google Gemini** (Gemini 2.5 Pro) — works for most agents
- **Moonshot Kimi** — experimental (some code-gen issues)
- **DeepSeek V3.2** — works for analysis agents (Distiller / Research / DocSmith); Sonnet on code-gen
- **Ollama** (local + cloud) — qwen3-coder-next:cloud works on analysis; local Llama / Mistral for budget builds
- **OpenAI Image** (DALL-E 3) — for icon generation only

Mix and match per-agent in Settings → Build Model Config.

---

## Why Anthropic over OpenAI / Gemini?

Tateru's pipeline uses two patterns where Anthropic still leads:
1. **Long structured JSON output** — Doc-Tor produces 50KB+ build specs with embedded widget trees. Sonnet handles brace-balance reliably; we've measured truncation rates with K2.6 / qwen3 / DeepSeek that don't transfer.
2. **Tool-call code generation** — Bob the Builder writes Dart files via tool calls. Claude separates "thinking" from "tool content" cleanly; some other models leak prose into the code body (MISTAKES rule #94).

You can absolutely run Tateru with OpenAI or Gemini — many agents work great. For Bob + Doc-Tor specifically, we've found Sonnet gives the highest first-try success rate.

---

## What kinds of apps can Tateru build?

Tateru builds **native Flutter apps** — real Android APKs you can install on a
phone, and (on a Mac, with an Apple Developer account) real iPhone builds
installed directly via Tateru. Custom app icons are generated and applied
across Android + iOS automatically.

✅ **Works well** — these are the categories Tateru has built end-to-end and
installed on real devices, usually first-try or close to it:

- **Productivity, habit & utility apps** — trackers, planners, checklists, mood/
  petty-wins loggers, daily-routine tools
- **Note-taking & journaling** — text + voice notes, tagging, search, local
  storage; voice-recorder journals with on-device transcription
- **Calculators, timers, converters** — tip/loan/unit calculators, countdown &
  interval timers, pomodoro-style focus apps
- **Music & audio players** — full iPod-style players with click wheel, library
  scanning, playlists, background playback + lock-screen controls
  (`audio_service` / `just_audio_background` / `on_audio_query` are auto-wired),
  album-art lookup, and AI track synopsis
- **Audio recording & monitoring apps** — record, waveform/amplitude display,
  playback, share
- **BYOK AI chat & assistant apps** — bring your own Claude / OpenAI / Gemini /
  OpenRouter key; streaming chat, per-app system prompts
- **On-device AI apps** — document / PDF chat and offline assistants running
  against Gemma (LiteRT-LM), no cloud key required
- **GPS, maps & location apps** — route tracking, location logging, map display
- **Camera, photo & sensor apps** — capture, gallery, accelerometer/gyroscope-
  driven features
- **Simple games & playful apps** — coin-flip / dice / decision makers,
  calculator-plus-mini-game mashups, animated reveal/flip mechanics
- **Lifestyle & content apps** — divination/horoscope engines, generators,
  multi-screen browsing + CRUD apps over a local database
- **Skeuomorphic / device-mockup UIs** — retro-device, calculator-face, and
  control-panel layouts that scale correctly to any phone
- **Marketing websites & docs** — via GreenThumb: an audit + an auto-generated
  Next.js marketing site + Privacy / Terms / Quick Start / User Manual

🟡 **Works with refinement (1–3 Diagnose → Refine cycles):**
- Complex multi-screen navigation patterns
- Camera / microphone / location / biometrics permission flows (especially the
  iOS Info.plist side)
- Local SQLite databases with custom schemas + migrations
- Heavy custom theming, animations, and gesture handling
- Background services and notifications

If a build hits a snag, the in-app **Diagnose** button matches it against
Tateru's library of 140+ documented fixes and the **Refinement Agent** applies
the change — most issues clear in one or two cycles.

---

## Why do my refinement-rebuild cycles use tokens?

Refinement Agent re-reads the relevant project files + writes the fixed version. Cost depends on the size of the change but is usually $0.50–$3 per refinement.

---

## What's "Private Build Mode"?

Pro annual plan ($63/mo billed annually) disables ALL telemetry. Trial / Starter / Maker plans send anonymized error counts + agent timings to Tateru's cloud (we use this to improve the build pipeline — see Build Learnings).

Pro = nothing about your apps, your code, or your usage leaves your machine.

---

## What's Build Learnings?

When a build fails and you Diagnose + Refine to fix it, Tateru offers to **Save this fix to local learnings**. The next time Bob writes code or Diagnose runs, it loads your local learnings file and avoids the same bug.

Optionally (Trial/Starter/Maker tiers, default ON), every 48h Tateru sends an anonymized digest of your local learnings to our cloud. We review them, validate, and bake the best ones into the next bundled MISTAKES.md update — so every Tateru user benefits from your debugging.

Pro Annual = local learnings only, no upload. You can manually pull validated rules via Settings → Build Learnings.

---

## Why is my APK so big? (40–60 MB is normal)

Flutter apps include the engine (~10 MB), Material/Cupertino widgets (~5 MB), and any plugins you've enabled (audio, file access, ML, etc — each adds 1–10 MB). 40–60 MB is normal for a Tateru-built app.

To shrink:
- Remove unused features (each plugin is ~2–5 MB)
- Use `--split-per-abi` (gradle option) to ship per-architecture APKs (~25 MB each instead of 60)
- Skip on-device LLM features (Gemma is 1+ GB)

---

## I'm on Mac — can I deploy to iPhone?

Yes. One-time setup per project:
1. Open `<projectDir>/ios/Runner.xcworkspace` in Xcode.
2. Target Runner → Signing & Capabilities → tick "Automatically manage signing" → pick your Apple Developer Team.
3. Save, quit Xcode.
4. Plug in your iPhone, trust the Mac.
5. Pipeline page → iOS section → pick your iPhone → Install & Run on iOS.

Tateru's `flutter build ios --release` uses your team's automatic provisioning. Works with both free Apple Developer accounts (7-day expiry) and paid accounts ($99/year, 1-year provisioning).

---

## Can I move a project between machines?

Yes — see [Quick Start Guide → Import Project](#) section, OR:

1. **Export Project** (Pipeline page → top-right) on machine A → saves a `.tateru-project` zip.
2. Move the zip however (USB, Dropbox, AirDrop, scp).
3. On machine B → sidebar → **Import Project** → drop the zip.
4. If the project already exists on B, you'll be asked to **Replace existing project** (deletes old) or Cancel.
5. Status is preserved — no re-running the pipeline. Just **Rebuild APK** locally.

---

## What's the difference between Save Locally and Push to GitHub?

- **Save Locally** copies the full project (Dart source + Android scaffold + APK) to a folder on your machine, initialises a git repo, makes an initial commit. Your machine, your control.
- **Push to GitHub** does the above PLUS pushes to a new GitHub repo using a personal access token. Useful for sharing or CI integration.

Save Locally first → push to GitHub later if you want.

---

## My audit shows "Wrong owner / Wrong email" — what's going on?

The audit checks that your privacy policy / terms of use mention the same owner name + contact email that Tateru has for the project. If you skipped the owner/email questions during AI Spec, defaults are used and they probably won't match what the docs say.

Fix: re-run the audit's **Generate** button on the failing doc — it'll regenerate with the correct values pulled from your project metadata.

---

## Where does Tateru store my projects?

| OS | Path |
|---|---|
| Linux (AppImage / .deb) | `~/.config/tateru-pro-plus/data/projects/` |
| macOS | `~/Library/Application Support/tateru-pro-plus/data/projects/` |
| Windows | `%APPDATA%\tateru-pro-plus\data\projects\` |

Plus the SQLite DB at `<dataDir>/tateru.db` and your built artifacts at `<dataDir>/output_apps/`.

---

## Tateru crashed / opened to a blank window

Most common causes:
1. **Older beta with missing native dep** (Prisma engine, Sharp variant, adm-zip) — fixed in 9.29 + later. Upgrade.
2. **Corrupted DB row from earlier hotfix** — 9.30.3+ self-heals on first launch.
3. **WSL or unusual env vars** — `ELECTRON_RUN_AS_NODE=1` set anywhere will break Electron. Check `env | grep ELECTRON` in your shell.

If neither — launch from terminal to capture stderr + email **support@tateru.app** with the output.

---

## I want to refund / cancel

Settings → Account → Manage Billing → opens Stripe customer portal. Self-serve cancellation + refund within 14 days of any plan change.

---

## Where do I report a bug or request a feature?

Sidebar → **Send Feedback**. Or email **support@tateru.app**.

For build-pipeline bugs specifically, the **Diagnose** button on a failed build sends a structured report with diagnostics attached — that's the highest-signal channel.

---

Last updated: 2026-05-07
