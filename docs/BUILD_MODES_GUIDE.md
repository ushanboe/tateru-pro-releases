---
**App:** Tateru Pro
**Version:** 1.0.0-beta.9.34.15
**Owner:** KangaBlue.au
**Contact:** support@tateru.app
**Last updated:** 2026-06-08
---

# Build Modes — deep dive

Tateru gives you 6 ways to start a new app project. They all feed the same 9-agent pipeline downstream — they just differ in how you describe the app at the start. This guide covers each one in detail with worked examples.

## When to pick which

Decision tree:

```
What do you have?
├── A vague idea (1 sentence) → AI Spec
├── A clear vision (3+ paragraphs) → Manual Entry
├── A complete spec as JSON → JSON Upload
├── Screenshots of an app you want to clone → Clone App
├── No idea — want Tateru to suggest one → Discover
└── A .tateru-project archive from another machine → Import Project
```

If none of those fit, default to **AI Spec** — it's the most forgiving entry point.

---

## Mode 1 — Discover (AppScout)

**Use when:** you don't have a specific app in mind. You want Tateru to find an opportunity for you in the Play Store data.

### How it works

Tateru's Scout pipeline runs three agents in sequence:

1. **Market Scan** — pulls the top 30–50 apps in your search criteria from the Play Store via `google-play-scraper`. Filters out apps from blocked-brand list (Settings → Blocked Brands — empty by default).
2. **Review Miner** — fetches up to 200 reviews per app, filters by rating (1–3 star reviews are the goldmine for complaints), runs an LLM to extract:
   - Top 5 complaints (what users hate)
   - Top 5 feature requests (what users wish existed)
   - Top 5 praises (what users love — useful for "don't break this when cloning")
3. **Opportunity Scorer** — scores each app 1–10 on five dimensions:
   - **Market gap** — how poorly served is the current market?
   - **AI enhancement potential** — how much can AI improve this app?
   - **Technical feasibility** — how hard would it be to build a competitor?
   - **Revenue potential** — estimated monthly revenue
   - **Stack match** (Skills Match mode only) — how well does this match the user's tech stack?

### Sub-mode 1A — Manual Search

**Best when:** you have a vertical in mind (fitness, productivity, finance) and want to explore opportunities within it.

**Field reference:**

- **Keyword Search** (free text, optional) — a Play Store search term. Examples: "habit tracker", "meal planner", "budget", "running coach".
- **Category** (dropdown, 33 options) — Play Store category. Combine with keyword for narrow searches, or leave blank to scan the whole category.
- **Platform** (button group: Android / iOS / Both) — currently only Android scrape is wired; iOS / Both display same Android results labelled accordingly. Roadmap: real iOS scrape via App Store API.
- **Min Downloads** (dropdown) — Any / 10K+ / 100K+ / 1M+ / 10M+. Filter out apps below this download threshold. **Tip:** start at 100K+ to avoid the long tail of low-quality entries; lower if your vertical is niche.
- **Min Revenue** (dropdown) — Any / $1K+ / $5K+ / $10K+ / $50K+. Estimated monthly revenue (downloads × ARPU based on price tier + ad presence). Useful for filtering out free apps with no clear monetization.
- **Desired Features** (free text, optional) — features you want the discovered apps to have. The Opportunity Scorer uses this to bias toward apps where these features could improve the experience.

**Worked example:**

> Goal: find a productivity app I could improve with AI.
>
> Settings: Category = Productivity, Keyword = "task manager", Platform = Android, Min Downloads = 100K+, Min Revenue = $1K+, Desired Features = "AI task suggestions, smart prioritization"

Result (typical): 8 apps surface, scored 5–9. Top 3 might be: "TaskMaster Pro" (score 8 — heavy reviews complaining about clunky UI; AI rewrite could be a serious win), "DailyHabit" (score 7 — strong base, lacks AI), "TickTickClone" (score 6 — saturated market but AI scheduling is missing).

### Sub-mode 1B — Auto-Discovery

**Best when:** you want Tateru to surprise you. Useful when starting a new project and you genuinely don't know what category to attack.

**Field reference:**

- **Focus Category** (dropdown, optional) — pick a category to scan, or leave as "All Categories" for Tateru to pick a high-opportunity one for you.

How it works internally:

- If Focus Category is set → same as Manual Search with no keyword
- If "All Categories" → Tateru runs a small LLM call ("based on current Play Store trends, which 3 categories have the highest opportunity score for an indie dev?") then scans the top of one

### Sub-mode 1C — Skills Match

**Best when:** you want apps you could actually build. The Opportunity Scorer biases toward apps that match your stack.

**Field reference:**

- **Your Tech Stack / GitHub Repo URL** (textarea) — either:
  - **Paste a public GitHub URL** (e.g. `https://github.com/yourname/yourrepo`) — Tateru hits GitHub's public API:
    - `/repos/{owner}/{repo}/languages` → returns language byte breakdown
    - `/repos/{owner}/{repo}/contents/package.json` → Node deps (if present)
    - `/repos/{owner}/{repo}/contents/pubspec.yaml` → Flutter deps (if present)
    - `/repos/{owner}/{repo}/contents/requirements.txt` → Python deps (if present)
    - `/repos/{owner}/{repo}/contents/Cargo.toml` → Rust deps (if present)
    - Synthesises a single tech-stack string used downstream
  - **OR describe your stack as free text** (e.g. "React Native, TypeScript, Node.js, PostgreSQL, AWS, TensorFlow")

How the matching works:

1. A small Haiku LLM call maps your tech stack → best-matching Play Store category + 1-3 search keywords
   - E.g. Unity → GAME / "puzzle game"
   - Flutter+audio → MUSIC_AND_AUDIO / "music player"
   - TensorFlow+Python → HEALTH_AND_FITNESS / "AI symptom checker"
2. The standard Manual Search flow runs with those derived params
3. Each scored app gets an additional `stackMatch` rating: strong / moderate / weak / unknown

**Worked example:**

> Stack: "Flutter, Riverpod, sqflite, just_audio, audio_service"
>
> Derived: category MUSIC_AND_AUDIO, keyword "music player"
>
> Top results: 8 music players in the Play Store. Each scored 1–10 with stackMatch indicating how realistic it is for you to build a competitor.

### Reading the Discover results page

After the Scout pipeline completes, you land on `/scout/results/<jobId>`. Layout:

- **Job summary** — your search params + total apps scanned + total opportunities surfaced
- **Opportunities table** — sortable by score, name, downloads, revenue
- **Click any row** → opens the **Deep Dive Brief** for that app

### Deep Dive Brief

Full LLM-written spec for a competitor app. Sections:

1. **Hero / positioning** — 1-line tagline, target audience, differentiation
2. **Core features** (5–10) — toggle on/off, edit each
3. **AI enhancements** — features that should use AI, with descriptions of what the AI does
4. **Recommended tech stack** — Flutter packages + state management choice
5. **Estimated build complexity** — file count + estimated cost + ETA

Buttons:

- **Edit features** — modify the brief before sending to build
- **Send to Build** → opens the New Project page in **AI Spec** mode with the brief pre-loaded as the conversation seed
- **Save Brief** → stores the brief; you can come back later via `/scout/deep-dive/<id>`

---

## Mode 2 — AI Spec

**Use when:** you have a fuzzy idea and want Tateru to ask clarifying questions to disambiguate.

### How it works

A chat panel where Tateru's "Spec Chat" agent has a structured conversation with you:

1. You type your initial idea ("a habit tracker for runners that uses AI to suggest training plans")
2. The agent asks clarifying questions, one at a time:
   - "How should training plans adapt? Based on past performance, weather, training load, or all three?"
   - "Do you want voice coaching during runs, or just visual stats?"
   - "Should the app sync to Strava / Garmin / Apple Health, or be standalone?"
3. You answer each one
4. After 3–5 exchanges, the agent decides it has enough and produces a structured JSON spec inline in the chat:
   ```json
   {
     "name": "RunCoach AI",
     "description": "...",
     "coreFeatures": [...],
     "aiEnhancements": [...],
     "platform": "android",
     "navigation": "bottom_tabs",
     ...
   }
   ```
5. Above the JSON, a **"Use this spec"** button appears → takes you into the New Project page with the spec pre-filled

### Field reference

- **Send a message** (chat input, multi-line) — your description / answers
- **Model selector** (dropdown, top of chat) — picks which AI handles the conversation. Defaults to **Claude Haiku 4.5**:
  - **Claude Haiku 4.5** (default) — cheap, fast, good for straightforward ideas. ~$0.001 per message.
  - **Claude Sonnet 4.6** — slower, more nuanced, asks better follow-ups for complex ideas. ~$0.01 per message.
  - **Claude Opus 4.6** — overkill for spec chat unless your idea is genuinely novel. ~$0.05 per message.
  - **GPT-4o** — alternative if you prefer OpenAI's questioning style.
  - **GPT-4o Mini** — equivalent to Haiku in price/speed.
- **Restart conversation** (button) — clear chat history and start over

### Operating modes

The Spec Chat agent has two operating modes built into its prompt:

1. **Default behaviour** — if your first message is descriptive enough (1+ sentences with a clear idea), the agent infers reasonable defaults and emits the JSON immediately. The wizard is your review step — Tateru's prompt explicitly tells the model: "if the user describes the app in 1+ sentences, ship the JSON in one fenced block; don't replay the wizard as chat".
2. **Conversational mode** — if your first message is vague ("a chat app"), the agent enters question-by-question mode.

This means: **if you give a complete description up front, you get an immediate spec.** If you give a stub, you get questions.

### Worked example (immediate spec)

> You: "An offline-first habit tracker for runners. Tracks daily runs (distance, pace, route). Suggests training plans using AI based on the last 4 weeks of data. Syncs to Strava optionally. Material You theming."
>
> Agent: "Here's the spec. Tap 'Use this spec' to start building." (JSON follows)

### Worked example (conversational)

> You: "a fitness app"
>
> Agent: "What kind of fitness — strength training, running, yoga, general workouts?"
>
> You: "running"
>
> Agent: "Should it work offline, online, or both? And do you want it to sync with anything (Strava / Apple Health / Garmin)?"
>
> You: "offline-first, optional Strava sync"
>
> Agent: "What's the AI doing — coaching, plan generation, route suggestions, all three?"
>
> You: "plan generation based on past runs"
>
> Agent: (enough info — emits JSON)

---

## Mode 3 — Manual Entry

**Use when:** you know exactly what you want and don't need the AI's help to spec it.

### How it works

A standard form. No LLM calls — pure UI-driven spec creation.

### Field reference

**Section 1 — Basic info**

- **App Name** (required) — used in the project slug, app title, doc headers, GitHub repo name
- **Tagline** (1-line description shown on the home screen) — short pitch
- **Category** (dropdown, 33 Play Store categories)
- **Target audience** (free text) — examples: "students aged 14-22", "small-business owners", "frequent travelers"

**Section 2 — Description**

- **Description** (long text, multi-paragraph) — what the app does in 2-5 sentences. Doc-Tor uses this verbatim, so be concrete.

**Section 3 — Core Features**

Pre-populated with 5 stub features you can replace. For each:

- **Feature name** (required) — e.g. "Add habit"
- **Description** (required) — what the feature does, 1 sentence
- **Add Feature** button — append a new stub
- **Remove** (×) per feature — delete

**Recommendation:** 5–15 core features for a typical app. Below 5, the app feels thin. Above 15, build cost and complexity rise sharply.

**Section 4 — AI Enhancements**

Same shape as Core Features but for AI-powered features:

- **Feature name** — e.g. "Smart reminders"
- **Description** — what the AI does, what input/output

Each AI enhancement gets classified by Build Architect downstream as:

- ✅ **Functional** — pure UI, local processing, BYOK API call (e.g. "summarize text using user's OpenAI key")
- ⚠️ **Needs Cloud API** — requires server-side inference (e.g. "user-uploaded image classification") — Tateru can't ship this in a pure-Flutter app
- ❌ **Not Buildable** — on-device ML for arbitrary tasks, real-time multi-user sync, payment processing

If the spec has Not-Buildable features, they get dropped from the build with a warning, but the rest of the app still ships.

**Section 5 — Tech Stack** (read-only summary)

Shows what Tateru will use by default:

- Flutter (latest stable)
- State management: Riverpod 2.x
- Local DB: sqflite (or Hive for simpler key-value)
- Navigation: go_router
- Theming: Material You
- (any other features-derived deps)

You can override per-agent in Settings → Build Model Config, but the defaults are well-curated for typical apps. Bob has a 130-rule MISTAKES library to avoid known package pitfalls.

**Section 6 — Owner info**

- **Owner Name** (required) — appears in Privacy Policy + Terms of Use
- **Owner Email** (required) — appears in Privacy + Terms + bug reports

**Submit:**

- **Create Project** → takes you to the Pipeline page where the project is in TEMPLATE status. Click **Start Pipeline** to begin the build.

---

## Mode 4 — JSON Upload

**Use when:** you have a complete spec as JSON. Power-user mode — useful for batch builds, A/B testing variations on a spec, or seeding the pipeline from another tool.

### How it works

A single textarea on the New Project page. Paste JSON, click validate, click Create.

### Schema

Minimal example (every field required unless marked optional):

```json
{
  "name": "MyApp",
  "description": "A habit tracker for daily routines.",
  "platform": "android",
  "tagline": "Build better habits, one day at a time",
  "category": "PRODUCTIVITY",
  "ownerName": "Your Name",
  "ownerEmail": "you@example.com",
  "coreFeatures": [
    { "name": "Add habit",     "description": "User adds a daily habit." },
    { "name": "Track streak",  "description": "Daily check-in updates streak counter." },
    { "name": "View history",  "description": "Calendar view of completed days." }
  ],
  "aiEnhancements": [
    { "enhancement": "Smart reminders", "description": "AI suggests reminder times based on user's check-in patterns." }
  ]
}
```

Optional fields:

- `targetAudience` (string) — e.g. "students aged 14-22"
- `tags` (array of strings) — surfaces in Trend Cast for audience matching
- `navigationConfig` (object) — explicit navigation spec; if omitted, Build Architect infers
- `design` (object) — `{ "iconPack": "material" | "cupertino" | "lucide", "primaryColor": "#3b82f6" }`
- `monetization` (object) — `{ "model": "free" | "freemium" | "paid", "tiers": [...] }` — note: monetization is a hint to Doc-Tor, not actual implementation. Tateru doesn't generate IAP code (yet).

### Buttons

- **Validate & Create** — parses JSON, checks required fields, creates the project on success
- **Load template** — pastes a starter JSON skeleton you can edit
- **Format JSON** — pretty-prints whatever's in the textarea

### Worked use case — batch builds

If you have a Python script that generates 5 variations of a spec:

```python
import json
specs = [...]  # 5 variations
for spec in specs:
    response = requests.post('http://localhost:8081/api/build/projects',
                             json=spec)
    project_id = response.json()['id']
    # ... start pipeline
```

JSON Upload mode is essentially the manual UI for the same `/api/build/projects` endpoint — useful for testing without writing a script.

---

## Mode 5 — Clone App

**Use when:** you want to reverse-engineer an existing app from screenshots.

### How it works

1. You drop 1–8 PNG screenshots of an existing app
2. **GPT-4o (vision)** reads them, identifies the app, infers features + screens + data flows
3. Output: a Tateru-shaped JSON spec that opens in the New Project form for editing

### Field reference

- **Choose images** button → file picker
  - **OR** drag-and-drop area — drop PNGs anywhere on the page
- **App name** (optional) — helps the analyzer if the screenshots don't clearly show the app's branding
- **Description** (optional) — 1-line hint about what the app does (helps with ambiguous screens)

After uploading 1–8 images, click **Analyze**.

### What happens during analysis

1. Tateru sends the images to OpenAI's `gpt-4o` chat-completions endpoint with a detailed system prompt asking it to identify:
   - App name + category + likely target audience
   - Each screen visible (name + purpose)
   - Each interactive element on each screen
   - Inferred data model (what entities exist)
   - Inferred navigation pattern (tabs / drawer / stack)
   - Likely tech stack (any clues from the UI style)
2. GPT-4o returns a structured JSON spec
3. Tateru parses it and opens the New Project form pre-filled

### Quality factors

- **Screenshot quality matters.** Crop tightly to just the app (avoid status bar / nav bar of your test device), avoid blurry shots, prefer light backgrounds for darker UIs (and vice versa).
- **Cover distinct features.** 8 screenshots of the same screen = wasted budget. 8 screenshots covering 8 different screens = ideal.
- **Include the home screen first.** Helps the analyzer get the app's overall purpose right.
- **8 max.** Beyond that, GPT-4o input cost goes up significantly with diminishing returns on accuracy.

### Cost

- ~$0.05–$0.15 per Clone analysis — depends on image count + resolution
- Anthropic key still needed for downstream code generation (this is the only mode that uses an OpenAI key for the spec itself)

### Limitations

Clone is at its best for **straightforward consumer apps** where the UI implies the data model clearly (todo lists, habit trackers, simple e-commerce, basic social). It struggles with:

- **Complex multi-step workflows** (checkout flows, multi-tab forms) — needs more screenshots than 8
- **Heavy custom rendering** (games, AR overlays, custom canvas drawing) — GPT-4o can't infer the rendering model from a static screenshot
- **Backend-heavy apps** (anything where the screenshots are mostly placeholders for server data) — GPT-4o sees what you show it; it can't infer what server endpoints exist

For those, **Manual Entry** + a thoughtful spec is faster than Clone + manual cleanup.

---

## Mode 6 — Import Project

**Use when:** you exported a `.tateru-project` archive from another machine and want to continue working on it locally.

### How it works

1. Drag-and-drop a `.tateru-project` zip onto the Import card (or click to file-pick)
2. Tateru shows a preview:
   - App name + tagline
   - File count + total size
   - Source machine info (OS, hostname if shared)
   - Status when exported (READY / FAILED / TEMPLATE)
   - Created at + last updated at
3. If a project with the same slug already exists locally, you're shown:
   - **Replace existing project** (amber primary action — deletes the existing project's DB row + on-disk dir before importing)
   - **Cancel** (default)
4. If no slug conflict, just **Import** appears
5. Click → archive extracts to `~/.tateru-pro/data/projects/<slug>/`, project row created in your local DB

### What's preserved

- All source files (DB rows + on-disk content)
- Agent logs from the source machine's pipeline run
- Audit + refinement history (if you toggled them on at export time)
- Project status — READY / FAILED preserved; mid-pipeline phases reset to TEMPLATE because the source orchestrator's state doesn't apply locally
- Owner name + email
- Build Doc + Spec (for re-running the pipeline if you want)

### What's NOT preserved

- Output APK (binary differs per machine — rebuild locally with **Rebuild APK**)
- API keys (always machine-local, never in the archive)
- License JWT (machine-local)
- Build settings (e.g. Telegram bot token — machine-local)
- Any local-mistakes.md learnings (machine-local Build Learnings)

### Worked use case — Mac → Linux round trip

> 1. On Mac: build an app end-to-end (status READY)
> 2. Pipeline page → Export Project → save `myapp.tateru-project` to Dropbox / iCloud / USB stick
> 3. On Linux: open Tateru → Import Project → drop the archive
> 4. Status preserved as READY — no need to re-run the LLM pipeline ($25+ saved)
> 5. Rebuild APK locally — works because all the source is in the archive
> 6. Install on Android phone via Tateru's wireless ADB

### Worked use case — same machine, replace existing

> Build version 1 of an app → save snapshot as v1.tateru-project
> 
> Iterate on the app via Refinement Agent → end up at v3
> 
> Don't like v3 → import v1.tateru-project → "Replace existing project" → back to v1

The export format is your safety net for "I want to try a major refactor without losing the working baseline".

---

## The "Look & Feel" picker (every mode)

Whichever mode you start in, the New Project flow includes a unified **"Look & Feel"** design step. It lets you give your app a cohesive visual identity before it's built — and the chosen theme is built straight into a good-looking, *functional* app. (This single picker replaces the old standalone "Themed Build" sidebar entry and the separate theme-picker step, and supersedes the external tateru-ux tool.)

### How it works

The picker has three axes, chosen in order, each with 10 options:

1. **Vibe** (10 options) — the overall feel (e.g. Modern Minimal, Warm Organic, Cool Professional, Soft Pastel, …). Picking a vibe **pre-selects a cohesive default colour scheme + font** that suits it.
2. **Colour scheme** (10 options) — the palette. Each scheme produces matching light + dark themes automatically. Pre-filled from your vibe; override freely.
3. **Font** (10 options) — the typeface (Google Fonts). Also pre-filled from your vibe; override freely.

That's **10 × 10 × 10 = 1,000** combinations. A **live preview** updates as you change any axis, so you can see the result before building.

### Recommended and Skip

- **Recommended** — one tap applies a cohesive, sensible default (vibe + colour + font) if you'd rather not fiddle.
- **Skip** — skips theming entirely and produces a **plain build** (no opinionated palette/font applied). You can always theme later.

### What you get

The chosen theme isn't a cosmetic afterthought — it's compiled into the app: a real Material 3 colour scheme (light + dark), the selected font, and a style direction passed to the builder so the generated app looks intentional and consistent across every screen, while remaining fully functional.

---

## Comparing the modes — quick reference

| Mode | LLM cost (spec phase) | Time-to-spec | Best for |
|---|---|---|---|
| Discover | $0.50–$3 (Scout pipeline) | 5–15 min | Finding opportunities |
| AI Spec | $0.01–$0.10 (Spec chat) | 2–10 min | Vague ideas, fast iteration |
| Manual Entry | $0 | 5–30 min | Clear vision, no LLM needed |
| JSON Upload | $0 | <1 min | Power users, batch builds |
| Clone App | $0.05–$0.15 (GPT-4o vision) | 30 sec – 2 min | Reverse-engineering existing apps |
| Import Project | $0 | <30 sec | Cross-machine project portability |

All modes feed the same **build pipeline** downstream — Distiller → Thinker Bell → Build Architect → Doc-Tor → Bob → Icon → DocSmith → Agent Orange → Test Generator → Feature Auditor. The build pipeline cost ($1–$50+ depending on app size + model preset) is independent of which mode you use to start.

---

## What if I picked the wrong mode?

You can always switch:

- **Started in AI Spec, want to switch to Manual Entry?** — In the chat, ask the agent for the JSON spec, then close the chat and use Manual Entry with the same content
- **Discovered an opportunity but the brief needs major edits?** — Click Send to Build, then use the Edit Spec button on the Pipeline page to modify before approval
- **Cloned from screenshots but the result is wrong?** — Edit the JSON in Manual Entry mode, OR start over with better screenshots

Until you hit "Start Pipeline" on the Pipeline page, no LLM cost has been spent on the build itself — only the spec-phase cost.

---

*See also: [USER_MANUAL.md](USER_MANUAL.md) for the full app reference, [QUICK_START.md](QUICK_START.md) for first-build walkthrough, [GREENTHUMB_GUIDE.md](GREENTHUMB_GUIDE.md) for the audit + website flow.*
