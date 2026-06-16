---
**App:** Tateru Pro
**Version:** 1.0.0-beta.9.34.16.13
**Owner:** KangaBlue.au
**Contact:** support@tateru.app
**Last updated:** 2026-06-15
---

# GreenThumb — audit + marketing site generator

GreenThumb is Tateru's "App Polisher" — it takes a finished app project and helps you ship it to the world. It does two distinct things:

1. **Audits** your project against a 4-check quality bar — docs, legal, icon, web presence
2. **Generates a Next.js marketing website** ready to deploy to Vercel (or anywhere that hosts Next.js)

You access it via the sidebar: **Website & Docs**.

---

## Prerequisites — Node.js LTS (GreenThumb only)

GreenThumb runs on **Mac, Windows, and Linux** — the audit + marketing-site generator works on all three platforms.

GreenThumb is the **only** part of Tateru that needs **Node.js**. Install **Node.js LTS** (18 or newer) before generating or previewing a website: the marketing-site generator runs `npm install` plus a Next.js preview server, both of which require Node + npm on your machine.

> **Node.js is NOT needed for app builds.** The Flutter app build pipeline (Discover → Develop → Launch) does not use Node at all. You only need it for GreenThumb's website + docs generation. Install it from [nodejs.org](https://nodejs.org/en/download).

If Node isn't installed, the audit checks still run fine — only the website-generation + preview steps require it.

---

## When to use GreenThumb

After a Tateru build completes (or against any existing local/GitHub Flutter project), use GreenThumb to:

- Verify your app has the legal docs it needs to ship to the Play Store (Privacy Policy, Terms of Use)
- Verify your user-facing docs (Quick Start, User Manual) are present and version-stamped
- Verify the app icon isn't a Flutter placeholder
- Generate a marketing website to drive downloads

You can also point GreenThumb at apps that **weren't built with Tateru** — point it at any local Flutter project or a GitHub repo, and it'll run the same 4 audits.

---

## Starting an audit

Three entry points:

### Path 1 — From a Tateru project (most common)

After your build is READY, on the Pipeline page → the **Build Website** card. It has three buttons — **Tateru Design** (templated, deployable), **Freeform Design** (one bespoke animated page), and **Fusion Design** (several models compete → best-of fused). Each runs the GreenThumb audit first (it gathers your docs/screenshots/icon/content), then opens the Audit Report focused on the design engine you picked.

- Tateru creates an AuditJob, the audit pipeline starts immediately
- The audit reads from `~/.tateru-pro/data/projects/<slug>/` (the live project state — mod 10.126 ensures this is the canonical source, not a stale save-local snapshot)
- You're navigated to the Audit Report page where you can watch the 4 checks run

### Path 2 — Load Local Repo

Sidebar → Website & Docs → **Load Local Repo** card.

- Pick a folder on disk — any Flutter project works (doesn't have to be Tateru-built)
- The audit creates an AuditJob with that folder as `repoPath`
- Same 4 checks run

### Path 3 — Load GitHub Repo

Sidebar → Website & Docs → **Load GitHub Repo** card.

- Paste a repo URL (e.g. `https://github.com/yourname/your-flutter-app`)
- For private repos: paste a GitHub Personal Access Token with `repo` scope
- Tateru clones the repo to a temp dir, audits, then cleans up

---

## The 4 audit steps

Each step runs sequentially. Status updates stream live to your browser.

### Step 1 — Identity & Docs

**Two agents run in parallel:**

**App Summary Agent** — reads:
- README.md (any case, any depth)
- main.dart (entry point — gives the app's class name)
- 1–3 representative screen files (sampled by file name + size)

Output:
- `appName` — populates the audit report header
- `appDesc` — used downstream for the marketing site copy
- `features` — auto-extracted feature list (this is what you edit in the Content Review modal before generating the website)

**Doc Audit Agent** — looks at the file tree for:

| Doc | Canonical path | Legacy path |
|---|---|---|
| Quick Start | `QUICK_START.md` (root, UPPERCASE) | `docs/quick_start.md` |
| User Manual | `USER_MANUAL.md` (root) | `docs/user_manual.md` |
| README | `README.md` | `readme.md` |

For each doc:

- ✅ **Present** — file exists on disk (filesystem-first detection per mod 10.79; the LLM is consulted only for content quality assessment, never for "does this file exist" — that decision can NEVER depend on the LLM)
- ❌ **Missing** — no matching file
- ✅ **Current** — doc's `**Version:** X.Y.Z` stamp matches the version in `pubspec.yaml`
- ⚠️ **Outdated** — doc has a stamp but doesn't match. Audit log shows the actual stamp + expected version
- ⚠️ **No stamp** — doc exists but has no version header. Falls back to LLM-judged currency

The version-stamp check is **deterministic** — same doc, same pubspec → same answer every time, regardless of which LLM is configured. This was a Phase 14 fix; previously the LLM gave fuzzy answers that varied between runs.

### Step 2 — Legal compliance

**Legal Audit Agent** — finds:

| Doc | Canonical path | Legacy path |
|---|---|---|
| Privacy Policy | `PRIVACY_POLICY.md` | `docs/privacy_policy.md` |
| Terms of Use | `TERMS_OF_USE.md` | `docs/terms_of_use.md` |

For each:

- ✅ / ❌ Present (filesystem-first)
- ✅ / ❌ Owner name matches expected
- ✅ / ❌ Contact email matches expected

The "expected" owner + email come from your project's template metadata (`template.ownerName` / `template.ownerEmail`). For Tateru-built projects, these are set during the build. For external projects, they default to "App Developer" / "contact@example.com" unless you override on the audit-job creation API.

When a doc fails the email check, the audit log shows you exactly what email was found in the doc — so you can debug whether DocSmith substituted a placeholder vs. there's a real mismatch.

**Common cause of failure (mod 10.127 fix in 9.32.13+):** older DocSmith versions sometimes substituted `contact@example.com` placeholder into the Terms doc despite the user's real email being passed in context. The DocSmith SOUL was tightened in mod 10.127 to forbid 12 named placeholder patterns. New builds should always have the user's real email in both Privacy and Terms.

### Step 3 — Icon

**Icon Agent** — finds the app icon, displays it in the audit report.

Preference order (mod 10.84):

1. `android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png` (highest density)
2. → mipmap-xhdpi → mipmap-hdpi → mipmap-mdpi
3. → `assets/icon.png` (if you have one)
4. → iOS / macOS scaffold default — flagged as "default icon detected; replace before shipping" because this is the Flutter placeholder

The icon is shown alongside two buttons:

- **Regenerate Icon** — calls DALL-E 3 with your app's name + description; resizes for all required Android densities + adaptive icon foreground + iOS sizes
- **Push Icon to GitHub** — if your project came from GitHub, pushes the new icon to the repo

### Step 4 — Web Presence

**Web Presence Agent** — searches for an existing marketing website for your app.

- Google + Bing search for "<app name> + Android app"
- Looks for first-party signals: official-looking domain, app-specific subdomain, GitHub Pages, hosted at common providers
- Returns: ✅ Found URL + SEO snippet preview, OR ❌ Not found

If found, displays the URL with a click-to-open link.

If NOT found, shows the **Generate Marketing Website** button — see the next section.

---

## Generate Marketing Website

The big feature of GreenThumb. Builds a full Next.js site for your app — hero, features, screenshots, doc viewer, deploy buttons.

### Pre-flight — Content Review Modal

Click **Generate Website** → modal opens with editable inputs.

#### Section 1 — Features

Auto-populated from App Summary Agent's extraction. For each feature:

- Edit text inline
- **Remove** (×) — drop incorrect entries (common: device permissions misclassified as features)
- **+ Add feature** — append a new one

**Tip:** the marketing site's feature section is generated from this list. Quality of the site copy depends on quality of the feature list. Take the time to clean it up.

#### Section 2 — Brand Colour

- **Colour picker** (HTML5 native — opens your OS colour picker)
- **Hex value** field (mono — paste a hex like `#3b82f6`)
- **8 swatch presets** — Blue / Indigo / Purple / Pink / Red / Amber / Green / Cyan

The brand colour drives the site's accent — primary buttons, hero gradient anchor point, link colour. Pick something that matches your app's actual UI.

#### Section 3 — Marketing Angle (REQUIRED — mod 10.117)

Pick one of 5 presets OR write your own custom brief:

| Preset | Use when |
|---|---|
| **AI-First** | Your app's main differentiator is its AI features — emphasises local on-device LLM, zero API costs (BYOK), no subscription for AI features, complete privacy |
| **Privacy-Focused** | Your app stores everything locally, no tracking, no analytics — emphasises offline capability, local storage, user data control |
| **Consumer Friendly** | General consumer app — uses simple non-technical language, focuses on lifestyle benefits + ease of use, avoids jargon, frames features as solutions to everyday problems |
| **Developer Tool** | Your app is for developers — uses technical language, highlights APIs / integration points / extensibility / configuration / performance specs |
| **Performance** | Your app's pitch is speed + efficiency — emphasises fast startup, low battery usage, small app size |

Click a preset → its body fills the textarea below. Edit the body if you want to tweak.

**Custom mode** — clear the textarea and write your own brief in 2–4 sentences. Examples that work well:

> "Emphasize that this is the only Android task manager with on-device AI prioritization. Frame it as 'your inbox manager without the cloud risks'. Audience: privacy-conscious developers + small teams."

> "Position as the simplest possible meditation app. Audience: complete beginners. Avoid 'mindfulness jargon' — use plain language like 'calm', 'breathing', 'quiet time'."

The marketing angle flows verbatim into Doc-Tor's prompt so it shapes every generated headline / description / use case.

**Validation:** the Resolve button is disabled (greyed out) until you've picked a preset or typed a custom brief. Empty briefs were silently allowed pre-9.32.13 and produced generic off-brand copy — now blocked.

#### Section 4 — Website Model

Picks which AI **generates the marketing site itself** — the hero, features, use cases, and requirements sections. This is distinct from the Chatbot Model below (which only powers the deployed site's chat widget):

| Option | Best for |
|---|---|
| **Claude Sonnet 4.6** (default) | Recommended — best balance of quality + cost for site copy. |
| **Claude Opus** | Highest-quality copy for premium / flagship sites. |
| **GPT-4o** | OpenAI alternative. |
| **GPT-4o Mini** | Cheapest. |

The Website Model defaults to **Sonnet 4.6** and can also be set globally in **Settings → Website Model** (the picker here overrides it per-site). The generation pipeline below uses whichever model you pick.

#### Section 5 — Chatbot Model (mod 10.101)

Picks which AI powers the marketing site's chat widget:

| Option | Cost | Provider | Best for |
|---|---|---|---|
| **No Chatbot** | Free | none | Ship the site WITHOUT a chat widget. No API keys needed on deploy host. |
| **GPT-4o Mini** (recommended) | $0.15 / $0.60 per 1M tokens | OpenAI | Default. Cheapest + fastest. |
| **GPT-4o** | $2.50 / $10 per 1M tokens | OpenAI | Smarter — for premium / B2B sites. |
| **Claude Haiku 4.5** | $0.80 / $4 per 1M tokens | Anthropic | Anthropic-side option. |
| **Claude Sonnet 4.6** | $3 / $15 per 1M tokens | Anthropic | Best quality, highest cost. |

The generated site's `app/api/chat/route.ts` natively handles whichever provider you picked (no shared abstraction layer — single-purpose code per model).

You'll need to set the matching env var on your deploy host:

- OpenAI options → `OPENAI_API_KEY` env var on Vercel
- Claude options → `ANTHROPIC_API_KEY` env var on Vercel
- No Chatbot → no env var needed

The site's chat widget uses a per-app system prompt (mod 10.101) — generated once at build time from your app's name, description, and features. It mentions YOUR app specifically (no more KangaBlue placeholder text from earlier versions).

#### Generate

Click **Approve & Generate** → kicks off the generation pipeline.

### Generation pipeline (~3–8 min)

1. Copy the marketing-web template to `~/.tateru-pro/websites/<AppName>-web/`
2. Generate hero + features + use cases + requirements sections via LLM (uses your configured **Website Model** — defaults to Sonnet 4.6)
3. Generate the per-app chatbot system prompt (uses the picked Chatbot Model)
4. Render Privacy / Terms / User Manual / Quick Start as HTML pages
5. Generate matching PDFs of each doc (if Puppeteer's Chromium is available; otherwise PDF download links 404 — HTML pages still render — mod 10.99 graceful degradation)
6. Save site to disk; AuditJob.websitePath is updated

### After generation — buttons appear

| Button | What it does |
|---|---|
| **Open Preview** | Local Next.js dev server on port 4000 (or first free port from 4000+). Browser tab opens. |
| **Manage Screenshots** | Drop PNGs into placeholder slots in the manifest. Site auto-rebuilds with new images. |
| **Deploy** | Push to Vercel via integrated deployer. Asks for your Vercel token + project name. |
| **Download zip** | Full site source as a zip. Extract anywhere; deploy via your own pipeline. Visible feedback "✓ Saved (NN KB)" after download (mod 10.86, 10.87 — fixed Electron download flow). |
| **Regenerate Website** | Rebuild from scratch. Preserves screenshots. |
| **Delete Website** | Remove the site dir. Asks for confirmation. Doesn't touch the AuditJob row. |

---

## Freeform website designer (experimental)

Alongside the templated GreenThumb site, Tateru has a **freeform website designer** — an experimental alternative. Where GreenThumb fills a fixed Next.js template component-by-component, the freeform designer hands ALL of your app's real content (name, description, features, the user manual + quick-start + legal docs, the icon, and your real screenshots as visual reference) to one capable design model and asks it to design + build a complete, bespoke, **animated** single-page marketing site from scratch. The output is a self-contained `index.html` (Tailwind + an animation library via CDN) — no `npm install`, no build step; it just opens in a browser. The page itself is **marketing** (hero, features, showcase, a short getting-started teaser, CTA, footer); your docs (user manual, quick-start, privacy, terms) are written as **separate linked pages** next to it (`user-guide.html`, `getting-started.html`, `privacy.html`, `terms.html`) — the marketing page links to them from the nav/footer rather than dumping them inline.

You'll find it in the **Audit Report** (after running an audit), in its own panel below the GreenThumb website generator.

### How it works

1. **Pick a model** (dropdown before Generate):
   - **Claude Opus 4.8** — recommended default. Reliable, top design quality, sees your screenshots (vision).
   - **Claude Fable 5** — premium; may fall back to Opus if your account lacks access.
   - **Claude Sonnet 4.6** — faster / cheaper (also vision).
   - **Gemini 3 Pro** — Google; strong design + multimodal (designs around your screenshots). Needs a Google API key (`GEMINI_API_KEY`) in Settings → AI Providers.
   - **GLM-5 (Z.ai)** — coding-strong; **text-only here** (it does NOT see your screenshots), needs `Z_AI_API_KEY`.
   - **GLM-5.2 (Z.ai)** — pre-staged; selectable now but builds fail until your Z.ai account gets standalone-API access.

   If your chosen model is unavailable, it automatically falls back to Opus 4.8 → Sonnet 4.6, and each result shows which model actually designed it.

2. **Add your real screenshots** (recommended) — the freeform panel has its own screenshot upload. The model designs the showcase AROUND them and matches the palette to your actual screens. Without screenshots it leaves clean device-frame placeholders — it will NOT fabricate fake screens.

3. **Variants (1–3)** — generate 1, 2, or 3 distinct designs in parallel (each with a different steer — default / bold / minimal) so you can pick the one you like.

4. **Customize Motion (✨)** — a popup that controls how animated the site is. **This is the dial to turn up if a site feels under-animated:**
   - **Animation level** — Subtle / Balanced (default) / **Rich** / **Showcase**. Rich and Showcase make rich animation *mandatory* (maximalist) — use these for a lively, "wow" site.
   - **Library** — Auto / GSAP + ScrollTrigger / AOS / CSS-only / Motion One.
   - **Effects** (check any) — scroll-pinned sections, parallax, staggered text reveals, animated counters, magnetic buttons, marquee, aurora / gradient drift, 3D hover-tilt cards, scroll-progress nav, clip-path reveals.
   - **Motion feel** (snappy / smooth / bouncy / cinematic), **Hero treatment**, an optional **reference vibe** (e.g. "Linear", "an Awwwards site of the day"), and a **reduced-motion** guard (on by default).

   Your choices are remembered for next time.

5. **Generate** — usually 1–3 minutes per variant. The first variant opens automatically when ready.

### Refine

Under each generated variant there's a refine box — type a plain-English change ("make it punchier", "darker", "more playful") and the model rewrites the whole page (re-supplying your screenshots so they stay accurate). A refine **regenerates the entire page**, so it takes about as long as a fresh generation — give it 1–3 minutes.

### What you need

- An API key for whichever model you pick (Anthropic for Opus/Fable/Sonnet, Google for Gemini 3, Z.ai for GLM-5/5.2) in **Settings → AI Providers**.
- Honest content only — the designer uses your real docs and won't invent stats, ratings, or testimonials. The marketing page **links** to your docs (Getting Started, User Guide, Privacy, Terms) as separate pages — rendered faithfully + in full, not summarised.

> **Experimental:** the freeform designer is newer than the templated GreenThumb path and still evolving. For a predictable, deployable templated site use **Generate Marketing Website** above; use the freeform designer when you want a bespoke, animated, one-of-a-kind page.

---

## Fusion website designer (experimental)

The **Fusion** designer is the multi-model big sibling of Freeform. Instead of one model designing one site, **several models each design a complete marketing page in parallel, every candidate is rendered, a vision judge ranks them, and a fuser combines the best of all into one page.** You'll find it in the **Audit Report**, in the **Fusion Site** card.

### How it works

```
Distill (read docs + screenshots → brief) → Architect (brief → site spec)
→ Builders ×N (each model builds a full site) → Render → Judge (rank) → Fuse (best-of) → ★ Fused site
```

1. **Compete** — pick **2–4** builder models: **Opus 4.8 · Sonnet 4.6 · GLM-5** (Anthropic · Z.ai). *(GPT-4o is excluded — its short output cap truncates full sites.)*
2. **Judge / vision** — who reads the screenshots + ranks the renders: **Anthropic Sonnet 4.6** (default) or **Z.ai GLM-4.5V** (an independent judge from a different provider than the builders).
3. **Screenshots** — same upload as Freeform (shared store). The distiller studies them; every candidate designs around them.
4. **Customize Motion** — uses the same ✨ motion settings as Freeform (set them in the Freeform card).
5. **Generate Fusion Site** — a live pipeline grid shows each model moving through Build → Render with a timer. When done you get a **★ Fused site** (the headline — best of all combined) plus each individual candidate with the judge's scores.

Like Freeform, the page is **marketing-only** with your docs as **separate linked pages**.

### What you need

- API keys for the builders you pick (Anthropic for Opus/Sonnet, Z.ai for GLM) in **Settings → AI Providers**. GLM-4.5V (vision) also uses your Z.ai key.
- It's the heaviest path — several full-site builds + a judge + a fuse — so expect **~3–7 minutes and a few dollars** (BYOK) per run.

> **Experimental + note:** the **render gate + vision judge run in the packaged app** (Chromium is bundled there). In a browser/dev session the candidates still build and **Open** works, but there are no rendered thumbnails and the judge falls back to a simple heuristic (largest). The distiller's screenshot reading works everywhere.

---

## Manage Screenshots

After generation, the site has placeholder image slots. To populate:

1. Click **Manage Screenshots**
2. Modal shows the manifest — typically 4–8 slots (hero shot, feature 1, feature 2, etc.)
3. For each slot:
   - Drop a PNG / JPG (or click to file-pick)
   - The site previews the image inline
   - Tateru saves to `<site>/public/screenshots/<slot-id>.png`
4. Close modal → site picks up new images on next preview reload

Recommended:
- Use real screenshots from your app (not stock photos)
- Square or 9:16 (phone aspect) images work best in the default template
- 1080×1920 or higher for sharpness

---

## Deploy to Vercel

Click **Deploy** → modal asks for:

- **Vercel token** — get one at [vercel.com/account/tokens](https://vercel.com/account/tokens) (any non-restricted token works)
- **Project name** (defaults to your slug + "-web")

Click **Deploy** → Tateru runs:

1. `npm install` (if node_modules missing)
2. `npm run build` (Next.js production build)
3. Vercel CLI deploy via the API
4. Returns the live URL

Total time: ~3–7 minutes for a fresh deploy.

After successful deploy:

- Live URL displayed
- AuditJob updated with the URL (so future "Web Presence" audit runs find it)
- Set the env var the chatbot needs in Vercel dashboard → Project Settings → Environment Variables

---

## Regenerating after edits

If you edit your project (e.g. add a new feature) and want to regenerate the website:

1. Go back to GreenThumb (sidebar → Website & Docs)
2. Find the Audit Job → **Regenerate Website**
3. Goes through the Content Review modal again — features will be re-extracted, but you can edit
4. Click Approve & Generate
5. Old site dir is wiped, new one generated. Screenshots are preserved.

---

## Audit-only mode

If you don't want to generate a website — just want the 4 audit checks — that works too:

1. Run the audit (any of the 3 entry paths)
2. Audit completes; review the 4 step results
3. Don't click Generate Website
4. Action whatever the audit flagged — fix Privacy/Terms email mismatches, regenerate icon, etc.

The AuditJob lives in your DB indefinitely — you can come back any time, view the latest audit results, and (re-)run individual steps if needed.

---

## Audit history

Sidebar → Website & Docs → **History** tab → shows every AuditJob you've created.

For each:
- Date created
- App name (resolved from Step 1)
- Status (running / complete / failed)
- Whether a website was generated
- ⋯ menu — Open / Delete

Click any row to reopen the Audit Report.

---

## Common issues

### "All 4 doc checks come back missing even though my docs exist"

Most common cause: the audit ran against a stale snapshot. **Fix in mod 10.126 (9.32.13+):** the audit now always reads from `~/.tateru-pro/data/projects/<slug>/` first, falling back to `project.repoPath` only if the live project dir is gone. If you're seeing this on 9.32.13+ with a real project on disk, it's likely:

- The doc filenames don't match the canonical patterns. Audit looks for UPPERCASE root paths (e.g. `PRIVACY_POLICY.md`) OR legacy `docs/<lowercase>.md`. If your docs are in `markdown/` or `documentation/` they won't be found.
- Path-separator mismatch on Windows (older versions). Mod 10.81 fixed this; should not affect 9.32.13+.

### "Privacy says email correct, Terms says wrong email"

DocSmith generated Terms with a placeholder email. Mod 10.127 (9.32.13+) tightened DocSmith's prompt to forbid 12 named placeholder patterns. Older builds may still have the bug — fix:

1. Open `TERMS_OF_USE.md` in your project
2. Find any placeholder email (`contact@example.com`, `your@email.com`, `[Your Email]`, etc.)
3. Replace with your real email (the one in `template.ownerEmail`)
4. Save → re-run audit Step 2

OR: regenerate the project on 9.32.13+ — the prompt fix prevents the bug from reoccurring.

### "Generate Website fails on Mac with 'no such file or directory'"

Mod 10.98 (9.32.7+) fixed this. Cause was `templates/` not being bundled in the macOS .app, plus URL-encoded path returned by `import.meta.url`. If you're on 9.32.7+ and still seeing this, file a bug — should be fixed.

### "Website generated but the chat widget shows generic 'how can I help' text"

You're on a pre-9.32.10 version. Mod 10.101 added per-app chatbot system prompt generation. Upgrade to 9.32.10+ and Regenerate Website.

### "Download zip button doesn't trigger a download in Electron"

Mod 10.86 (9.32.x) fixed this via the fetch+blob+ObjectURL pattern + Electron `will-download` handler in main.ts. If you're on 9.32.x+ and still no download, check your browser/Electron's downloads folder — the file might be downloading silently. Mod 10.87 added explicit "✓ Saved (NN KB)" visible feedback to make downloads obvious.

### "rsync / cp / pgrep is not recognized" on Windows during regenerate

GreenThumb generates + previews websites on **Mac, Windows, and Linux** (just install Node.js LTS first — see Prerequisites above). The core generate + preview flow is cross-platform. A small number of website **regenerate / stop** paths historically used Unix shell commands; mod 10.125 (9.32.13+) replaced 6 `rm -rf` calls with cross-platform `fs.rm`, and the remaining sites (rsync@611, cp@621, pgrep@774) are tracked as 10.125b. If you hit a "not recognized" error specifically while stopping/regenerating an existing preview on Windows, restart Tateru and re-run, or delete the site with **Delete Website** and generate fresh.

---

## Privacy + telemetry

GreenThumb runs entirely on your machine + your AI providers. Tateru's cloud sees:

- Anonymous tally of how many audit jobs you've run (Trial / Starter / Maker only — Pro Annual = no telemetry)
- No project content, no doc content, no your app's data

Generated websites are stored in `~/.tateru-pro/websites/` — they never leave your machine unless you click Deploy or Push to GitHub.

The chatbot widget on a deployed site uses YOUR API key (via the env var on Vercel) — Tateru's cloud is not in that loop.

---

*See also: [USER_MANUAL.md](USER_MANUAL.md) for the full app reference, [BUILD_MODES_GUIDE.md](BUILD_MODES_GUIDE.md) for build-mode walkthroughs, [TROUBLESHOOTING.md](TROUBLESHOOTING.md) for common issue fixes.*
