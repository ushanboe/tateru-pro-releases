---
**App:** Tateru Pro
**Version:** 1.0.0-beta.9.32.13
**Owner:** KangaBlue.au
**Contact:** support@tateru.app
**Last updated:** 2026-05-11
---

# Trend Cast — predicting your app's launch performance

Trend Cast is Tateru's "Decide" tool — a 200-AI-agent simulation that predicts how your app will perform on the Play Store before you ship it. Think of it as a focus group made of synthetic users who behave like real ones, but at 1000× the speed and a fraction of the cost.

You access it via the sidebar: **Trend Cast**.

---

## What it actually does

Most "AI prediction" tools take a description and ask one model "will this succeed?". The model gives you confident-sounding garbage — there's no grounding, no audience model, no rigorous sampling.

Trend Cast does something different:

1. **Generates 200 synthetic user agents** — each with a profile (demographics, app preferences, willingness to pay, retention behaviour, current Play Store usage patterns)
2. **Shows each agent your app's pitch** — name, hero copy, screenshots (if provided), feature list
3. **Each agent independently scores** the app on multiple dimensions: install likelihood, retention at day 1 / 7 / 30, willingness to upgrade to paid, top objections + concerns
4. **Aggregates the scores** into a 15-section report

The "agents" are LLM personas, not real humans. The output isn't a market research study — it's a structured stress-test of your value proposition. Strong apps tend to score well; obviously broken pitches get caught.

The simulation runs in a Python sidecar (FastAPI) on your machine — port 5101, internal only, auto-started by Tateru. Communication is HTTP between the desktop API and the sidecar.

---

## When to use Trend Cast

Trend Cast is most valuable at three points:

1. **After a Discover session** — Discover suggested an app idea; Trend Cast tells you whether it's likely to actually take off
2. **Before publishing to Play Store** — sanity check on your hero copy / screenshots / monetization plan
3. **Comparing two app concepts** — run both, pick the one with the stronger projection

It's not useful for:

- Apps that are heavily B2B (not in the Trend Cast audience model — built for consumer apps)
- Apps with no clear value proposition (the model can only score what you give it)
- Apps where the value is in execution, not concept (Trend Cast can't see your actual code or UX quality)

---

## Running a prediction

### The Validate page

Sidebar → Trend Cast → opens the **Validate** page with two fields:

- **App Name** (required) — used in the simulation as the app's branded identity
- **Description** (required, long text) — what the app does + who it's for. Trend Cast uses this verbatim. Be concrete.

Click **Run prediction**.

### What happens during simulation

1. Tateru's TrendCast sidecar (Python FastAPI on `127.0.0.1:5101`) receives the request
2. Generates 200 synthetic user agents — sampled across demographics, app preferences, etc.
3. For each agent, runs a small LLM call: "given this user persona + this app pitch, score the app on [install likelihood / retention / monetization / objections]"
4. Aggregates the 200 individual scores
5. Runs a final LLM pass to write the 15-section report from the aggregate

Total time: 2–5 minutes for typical apps.

You see live progress on the page — sections fill in as the simulation runs. You don't need to wait — leave the tab open and Tateru will notify you when complete.

### Cost

Trend Cast uses your configured LLM provider (default: same as your Build Model preset).

| Preset | Typical cost per Trend Cast run |
|---|---|
| Budget (Haiku) | $1–$3 |
| Balanced (Sonnet) | $5–$15 |
| Premium (Opus) | $15–$40 |
| DeepSeek Hybrid | $2–$6 |

Heavier presets give more nuanced agent personas + better aggregate analysis. For a sanity check, Budget is fine. For a launch decision, Balanced or higher is recommended.

---

## The 15-section report

After the simulation, you land on the report page. Sections (in order):

### 1 — Executive summary

TL;DR — recommended action ("ship it" / "iterate before shipping" / "don't ship — pivot"), key reasons, top 3 risks. Read this first.

### 2 — Download projections

Predicted install counts at:
- Week 1 post-launch
- Month 1
- Month 3
- Month 6

Plus confidence interval (low / median / high) for each. Caveat: these are projections from a simulation, not real downloads. Treat them as relative magnitudes — "this app would likely outperform that app", not as absolute targets.

### 3 — Monetization fit

Whether your pitch fits free / freemium / paid models. Based on:
- Audience income segment estimates
- Direct competitor pricing (from the Play Store data Trend Cast has)
- Price elasticity inferred from the agents' upgrade likelihood at different price points

Output: "free recommended", "freemium recommended at $X/mo", "paid recommended at $X one-time", with reasoning.

### 4 — Top retention risks

What might cause users to drop off in the first 7 / 30 days. Common patterns:
- "Onboarding too complex — 23% of agents reported abandoning during signup"
- "Core value not visible until day 3 — users don't return after day 1"
- "AI feature requires paid API — 67% of agents found this unexpected and dropped"

### 5 — Top conversion blockers (freemium → paid)

If your pitch implies freemium, what stops users from upgrading. Common patterns:
- "Free tier is too generous — no clear upgrade trigger"
- "Paid features don't differentiate enough from free"
- "Pricing too aggressive for the segment"

### 6 — Audience segmentation

Who liked it vs who skipped. Breakdown by:
- Age bracket
- Income bracket
- Existing app preferences (e.g. "users of competing app X strongly liked your pitch")
- Tech sophistication level

This is one of the most actionable sections — it tells you who to target with your launch marketing.

### 7 — Sentiment heatmap (per app feature)

For each feature in your pitch, what % of agents reacted positively / neutrally / negatively. Useful for:
- Cutting features that don't resonate (drag on App Store conversion)
- Doubling down on features that do (lead with them in your hero)

### 8 — Competitive positioning

How your app compares to its closest 3–5 Play Store competitors. Includes:
- Feature parity matrix
- Price positioning
- Differentiation strength (1–10)

### 9 — Marketing channel fit

Which channels would convert best for this audience:
- Reddit (which subreddits)
- Twitter/X (which communities)
- TikTok
- ProductHunt
- Direct paid ads (which platforms)
- App Store search keywords

Each ranked by expected conversion + reach.

### 10 — App Store listing critique

If you provided screenshots, the agents review them. If not, a generic "what your listing should emphasize" guide based on the audience model.

### 11 — Onboarding friction analysis

How many steps from "tap install" to "first value moment". Suggests cuts.

### 12 — Pricing recommendations

For freemium / paid models, specific dollar amounts the agents thought were sweet spots. Aggregated from individual willingness-to-pay scores.

### 13 — Feature prioritisation

If you can only build N features for v1, which ones? Ranked by audience score × build complexity (lower complexity wins ties).

### 14 — Pre-launch action items

A checklist of things to do before shipping based on the previous sections. Examples:
- "Cut feature X — 73% of agents found it confusing"
- "Add screenshot showing AI feature in action — currently invisible from listing"
- "Move 'free trial' badge to hero, not feature list — increases install likelihood by est. 12%"

### 15 — Post-launch monitoring KPIs

What to track in the first 30 days:
- Day 1 retention target
- Day 7 retention target
- Conversion rate (if freemium)
- Top 3 metrics that would signal "iterate" vs "scale marketing"

---

## Reading + acting on the report

**The hardest part of Trend Cast is resisting the urge to over-trust it.**

Things to remember:

- The agents are LLMs, not real users. They can't tell you what your app actually feels like to use — they can only react to your pitch.
- Aggregate scores ARE noisy — a 7.2 vs a 7.4 is not a meaningful difference. Look at trends and outliers, not exact numbers.
- The report is best at catching obvious problems (broken value prop, missing pricing rationale, incoherent audience targeting). It's worst at predicting absolute success ("this will be a hit").
- If two pitches both score well, build both prototypes and run real user tests — Trend Cast tells you "neither has obvious problems", not "the higher-scoring one will win".

Use it as **one input** to your launch decision, alongside real user research, your own gut, and the Discover data on actual market gaps.

---

## Sending a prediction to a Build

After running Trend Cast, the report has a **Send to Build** button at the bottom. Clicking it:

1. Takes the app pitch you used for the prediction
2. Pre-fills the New Project page in **AI Spec** mode with the pitch as the conversation seed
3. The Spec Chat agent then asks clarifying questions and produces a build spec

This is the path: idea → Trend Cast (validate the concept) → Build (make it real). For a complete round-trip:

> Discover (find an opportunity) → Deep Dive Brief → Trend Cast (validate the brief) → Build (make it) → GreenThumb (audit + website) → Push to GitHub → ship to Play Store

---

## Trend Cast architecture

For the curious / for debugging:

- **Python sidecar** at `apps/trendcast/` — FastAPI server with 200-agent simulation engine
- **Auto-started** as a child process when Tateru's Express API boots (port 5101, 127.0.0.1 only)
- **Health monitored** every 15 seconds; auto-restarts after 3 consecutive failures
- **Communication** via HTTP from the desktop API → sidecar (with retries + 30s timeout)
- **Uses your AI provider keys** — passed through from the desktop API's env

If Trend Cast is unresponsive, check the system tray / Activity Monitor — there should be a `python` / `uvicorn` process. If not, restart Tateru and the sidecar will respawn.

---

## Privacy + data

What goes to the cloud:

- Trend Cast prompts go to YOUR configured LLM provider (Anthropic / OpenAI / etc.) — Tateru doesn't see them
- Anonymous prediction-count telemetry to Tateru's cloud (Trial / Starter / Maker only — Pro Annual = no telemetry)
- No project content, no pitch content, no audience model state leaves your machine

Reports are stored in your local DB indefinitely — you can revisit any past prediction via Sidebar → Trend Cast → History tab.

---

## Common issues

### "Trend Cast prediction never starts — stays at 'starting...'"

Check that the Python sidecar is running:

```bash
# On Linux/Mac:
ps aux | grep -i uvicorn

# On Windows (PowerShell):
Get-Process python | Where-Object { $_.MainWindowTitle -match 'uvicorn' }
```

If not running, the most common cause is missing Python deps. Tateru auto-installs them on first launch but if that failed:

```bash
cd apps/trendcast
python3 -m venv .venv
.venv/bin/pip install -r requirements.txt   # Linux/Mac
.venv\Scripts\pip install -r requirements.txt  # Windows
```

Then restart Tateru.

### "Prediction completes but report sections are empty"

LLM returned non-JSON output and the parser couldn't recover. Check the agent logs (Pipeline → Logs panel for the prediction). Most likely the configured Audit Model is set to a model that's drifted (e.g. older Haiku versions). Switch to Sonnet 4.6 in Settings → Audit Model.

### "Prediction cost was way higher than expected"

Heavy presets (Premium / Opus across the board) can run $30+ per Trend Cast on complex apps. Check Settings → Build Model Config and switch to Balanced for Trend Cast unless you specifically need Opus's nuance.

---

*See also: [USER_MANUAL.md](USER_MANUAL.md) for the full app reference, [BUILD_MODES_GUIDE.md](BUILD_MODES_GUIDE.md) for build-mode walkthroughs, [GREENTHUMB_GUIDE.md](GREENTHUMB_GUIDE.md) for audit + marketing site.*
