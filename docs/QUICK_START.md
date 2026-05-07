# Quick Start Guide

**App:** Tateru Pro
**Audience:** New users — your first app in 10 minutes.

Tateru Pro builds real Android apps from a description. You bring your own AI key (Anthropic recommended), Tateru runs the pipeline, and you get an installable APK.

---

## 1. Set up your AI key (one-time)

1. Click the **Settings** gear (bottom-left of the sidebar).
2. Under **AI Providers** → paste an Anthropic API key.
3. Click **Test** — should show ✓ Connected.

**Cost expectation:** ~$6–20 in Anthropic API credits per app, depending on complexity (calibrated against real Phase 20–22 builds). Tiny utilities are cheaper, complex multi-screen apps with AI features are higher. Money goes to Anthropic directly (BYOK), not to Tateru.

If you don't have a key yet:
- [console.anthropic.com](https://console.anthropic.com) → API Keys → create one.
- Add ~$20 of credits to start. After your first 2–3 builds, the in-app Spec Approval Panel switches to data-driven estimates based on YOUR actual build history.

---

## 2. Pick a build mode (sidebar)

| Mode | Best for |
|---|---|
| **Discover** | Browse Play Store gaps + opportunities |
| **AI Spec** | Describe your app in chat — Tateru asks the right questions |
| **Manual Entry** | You know exactly what you want — fill in a form |
| **JSON Upload** | Power user — paste a complete app spec |
| **Clone App** | Drop 1–8 screenshots; GPT-4o reverse-engineers the spec |
| **Import Project** | Bring an existing `.tateru-project` archive from another machine |

For your first app, **AI Spec** is the friendliest path.

---

## 3. Describe your app (AI Spec mode)

1. Sidebar → **AI Spec**.
2. Type a 1–2 sentence description: *"A pomodoro timer with statistics and a calming sound library."*
3. Tateru asks 3–5 follow-up questions (theme, target audience, must-have features).
4. Click **Build Spec** — your app's blueprint is ready.
5. Review the spec on the **Brief Review** screen. Toggle features off/on, edit the AI enhancements.
6. Click **Start Pipeline**.

---

## 4. Watch the pipeline (Pipeline page)

10 agents run in sequence. You'll see green checkmarks light up:

1. **Distill** — compress the brief
2. **Research** — find similar apps + frameworks
3. **Architect** — assemble the spec
4. **Docs** — write the build documentation (Doc-Tor)
5. **Build** — Bob writes the Flutter code
6. **Icons** — generate app icon (DALL-E 3)
7. **Post Docs** — write user-facing docs (DocSmith)
8. **Review** — Agent Orange reviews + fixes
9. **Test** — generate integration tests
10. **Audit** — Feature Auditor verifies everything works

Then the **APK** auto-builds (~3–5 min).

**Total: 10–25 min** for a typical app, depending on complexity + chosen models.

---

## 5. Install on your phone

When Pipeline page shows **Successfully Compiled Code!** + green Package + Ready tiles:

1. Plug your Android phone in via USB → enable **USB debugging** (Settings → Developer options).
2. Click **Install on Android** in Refine App panel.
3. The APK installs over ADB. Open it on your phone.

**Wireless install** (no cable): Settings → Wireless ADB Pairing → enter the pairing code from your phone's Developer options. Once paired, Install on Android works wirelessly.

**iOS install** (if you're on a Mac with Xcode): Pipeline page → iOS section → pick simulator or your iPhone → Install & Run on iOS.

---

## 6. Refine

Spotted something to change? Use the **Refine** panel:
- Click a preset issue (Themes don't change, Missing back buttons, etc.) → Refine
- OR type your own instruction: *"Add a dark mode toggle in Settings"* → Refine

Refinement Agent edits files, you Rebuild APK, install again.

---

## What can Tateru build well?

✅ **Works first try (most builds):**
- Productivity / habit / utility apps
- Simple games / calculators
- Note-taking / journaling
- BYOK AI chat apps (Anthropic / OpenAI / Gemini)
- Music players (audio_service / on_audio_query supported)
- PDF / document chat (on-device LLM via Gemma)

🟡 **Works with refinement (1–3 cycles):**
- Multi-screen apps with custom navigation
- Apps using camera / mic / location
- Local SQLite databases

❌ **Hard today (won't be perfect first try):**
- On-device ML beyond Gemma
- Real-time multiplayer
- Payment integration (Stripe / IAP)
- Complex animations / 3D

---

## Where to get help

- **Send Feedback** (sidebar) — bug reports + feature requests
- **Ask Bob** — coming soon: Bob the Builder explains code decisions
- **FAQ** — common questions
- **User Manual** — comprehensive feature reference

Or email **support@tateru.app**.

Happy building.
