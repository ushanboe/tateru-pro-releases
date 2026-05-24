#!/usr/bin/env bash
# Tateru Pro — clean macOS uninstaller (end-user script). Run on macOS.
#
# Quits the app and removes /Applications/Tateru Pro.app. By default it
# preserves your data (generated projects, built APKs, SQLite DB, Cloud
# login) so a reinstall picks up where you left off. Pass --purge to wipe
# everything for a true clean-slate.
#
# WHY THIS SCRIPT EXISTS: the old MACOS_INSTALL.md uninstall steps pointed
# at "~/Library/Application Support/Tateru Pro" — but Electron's
# app.getName() returns the package.json `name` ("tateru-pro-plus"), NOT
# the productName ("Tateru Pro"). So the real data dir is
# "~/Library/Application Support/tateru-pro-plus". The old `rm -rf` removed
# nothing, the reinstall reused the stale data + DB, and the app looked
# like the uninstall "didn't work". This script targets the correct paths
# (and the legacy ones too, belt-and-braces).
#
# Usage:
#   ./uninstall-macos.sh            # interactive — asks keep/wipe/cancel
#   ./uninstall-macos.sh --purge    # also delete projects/APKs/DB/login/caches
#   ./uninstall-macos.sh --yes      # don't prompt for confirmation (keeps data)
#   ./uninstall-macos.sh --yes --purge   # wipe everything, no prompts
#   ./uninstall-macos.sh --help
#
# One-liner (must use process substitution to preserve interactive stdin):
#   bash <(curl -fsSL https://tateru.app/uninstall-macos.sh)
#
# DON'T pipe via curl | bash — that hands curl's stdout to the script as
# stdin, breaking the interactive keep/wipe prompt. The script detects
# this and refuses to guess, printing the correct invocation instead.
#
# Best-effort throughout. Needs sudo only if the .app lives somewhere
# root-owned (normally it doesn't).

set -u

PRODUCT="Tateru Pro"
NAME="tateru-pro-plus"
APPID="com.tateru.pro.plus"
PURGE=0
ASSUME_YES=0

for arg in "$@"; do
  case "$arg" in
    --purge) PURGE=1 ;;
    --yes|-y) ASSUME_YES=1 ;;
    --help|-h)
      sed -n '2,28p' "$0" | sed 's/^# \{0,1\}//'
      exit 0 ;;
    *) echo "Unknown option: $arg (try --help)" >&2; exit 1 ;;
  esac
done

say()  { printf '  %s\n' "$*"; }
head() { printf '\n=== %s ===\n' "$*"; }

APP_BUNDLE="/Applications/${PRODUCT}.app"

# Data locations. The first of each pair is the CORRECT current path
# (Electron app.getName() = the npm `name`); the second is the legacy
# productName-based path the old docs referenced — removed too if present.
DATA_PATHS=(
  "$HOME/Library/Application Support/${NAME}"
  "$HOME/Library/Application Support/${PRODUCT}"
  "$HOME/Library/Caches/${APPID}"
  "$HOME/Library/Caches/${NAME}"
  "$HOME/Library/Logs/${NAME}"
  "$HOME/Library/Logs/${PRODUCT}"
  "$HOME/Library/Preferences/${APPID}.plist"
  "$HOME/Library/Saved Application State/${APPID}.savedState"
  "$HOME/.tateru-pro"
)

head "What was found"
[ -d "$APP_BUNDLE" ] && say "✓ App bundle: $APP_BUNDLE" || say "· App bundle: not in /Applications"

head "User data (kept unless --purge)"
FOUND_DATA=0
for p in "${DATA_PATHS[@]}"; do
  if [ -e "$p" ]; then
    FOUND_DATA=1
    say "• $p ($(du -sh "$p" 2>/dev/null | cut -f1))"
  fi
done
[ "$FOUND_DATA" -eq 0 ] && say "(none found)"

if [ ! -d "$APP_BUNDLE" ] && [ "$FOUND_DATA" -eq 0 ]; then
  echo
  say "Nothing to uninstall — no app bundle and no Tateru data on this Mac."
  exit 0
fi

# ----------------------------------------------------------------------
# Interactive mode selection (one-liner UX)
# ----------------------------------------------------------------------
# Behaviour matrix (mirrors uninstall-linux.sh):
#   --yes alone        → no prompts, current PURGE value used (0 by default)
#   --purge alone      → asks proceed-yes/no, mode is wipe
#   --yes --purge      → no prompts, full purge
#   neither, TTY stdin → 3-option keep/wipe/cancel + final proceed prompt
#   neither, no TTY    → refuse to guess (curl|bash mistake) + print guidance
#
# The bash <(curl -fsSL ...) invocation preserves interactive stdin;
# "curl | bash" doesn't, and is caught by the no-TTY branch below.

if [ "$ASSUME_YES" -eq 0 ] && [ "$PURGE" -eq 0 ]; then
  if [ -t 0 ]; then
    echo
    echo "You're about to uninstall ${PRODUCT}. Two options for your data:"
    echo
    echo "  [1] Keep my data  — remove the app, KEEP projects + APKs + DB + Cloud login"
    echo "                     (recommended — reinstall later picks up where you left off)"
    echo "  [2] Wipe my data  — remove app AND all user data listed above"
    echo "                     (clean-slate; cannot be undone)"
    echo "  [3] Cancel        — quit without changing anything"
    echo
    printf 'Choose [1/2/3] (default: 1): '
    read -r choice
    case "${choice:-1}" in
      1|k|K|keep|KEEP) PURGE=0 ;;
      2|w|W|wipe|WIPE|purge|PURGE) PURGE=1 ;;
      3|c|C|cancel|CANCEL|q|Q) echo "Cancelled."; exit 0 ;;
      *) echo "Unknown choice '$choice' — aborting for safety."; exit 1 ;;
    esac
  else
    # Non-interactive (probably piped via "curl | bash" instead of
    # "bash <(curl ...)"). Refuse to guess about user data.
    echo
    echo "❌ Uninstaller can't ask about your data because stdin isn't a terminal."
    echo
    echo "   You probably ran:   curl ... | bash"
    echo "   Use this instead:   bash <(curl -fsSL https://tateru.app/uninstall-macos.sh)"
    echo
    echo "   Or pass flags explicitly:"
    echo "     curl ... | bash -s -- --yes              # keep data, no prompts"
    echo "     curl ... | bash -s -- --yes --purge      # wipe data, no prompts"
    exit 1
  fi
fi

echo
if [ "$PURGE" -eq 1 ]; then
  say "MODE: full removal + PURGE — the app AND all user data above will be deleted."
else
  say "MODE: app removal only — user data above is PRESERVED."
fi
if [ "$ASSUME_YES" -eq 0 ]; then
  printf '\nProceed? [y/N] '
  read -r reply
  case "$reply" in
    y|Y|yes|YES) ;;
    *) echo "Aborted."; exit 0 ;;
  esac
fi

# ----------------------------------------------------------------------
# 1. Quit the running app
# ----------------------------------------------------------------------
head "Quitting ${PRODUCT}"
osascript -e "quit app \"${PRODUCT}\"" 2>/dev/null && say "asked the app to quit"
# Give it a moment, then force any stragglers (helper processes, hung window).
sleep 1
if pgrep -f "${APP_BUNDLE}/Contents/MacOS" >/dev/null 2>&1; then
  pkill -f "${APP_BUNDLE}/Contents/MacOS" 2>/dev/null && say "force-stopped remaining processes"
fi
say "done"

# ----------------------------------------------------------------------
# 2. Remove the .app bundle
# ----------------------------------------------------------------------
head "Removing the app bundle"
if [ -d "$APP_BUNDLE" ]; then
  if rm -rf "$APP_BUNDLE" 2>/dev/null; then
    say "removed $APP_BUNDLE"
  else
    sudo rm -rf "$APP_BUNDLE" && say "removed $APP_BUNDLE (with sudo)"
  fi
else
  say "not present — skipped"
fi

# ----------------------------------------------------------------------
# 3. Purge user data (only with --purge)
# ----------------------------------------------------------------------
PURGE_FAILED=0
FAILED_PATHS=""

if [ "$PURGE" -eq 1 ]; then
  head "Purging user data"

  # Kill lingering Tateru-spawned processes that may hold files open in
  # ~/.tateru-pro/ or the Library data dirs — notably the Next.js dev
  # servers GreenThumb spawns for marketing-site previews (mod 10.183).
  # Without this, "rm -rf" can fail with "Directory not empty" when a
  # child is actively writing. All pkills are best-effort.
  pkill -f "${APP_BUNDLE}"        2>/dev/null || true
  pkill -f "tateru-pro-plus"      2>/dev/null || true
  pkill -f "$HOME/.tateru-pro"    2>/dev/null || true
  pkill -f "node.*next.*dev"      2>/dev/null || true
  sleep 1  # let the kills propagate so file handles release before rm

  for p in "${DATA_PATHS[@]}"; do
    [ -e "$p" ] || continue
    if rm -rf "$p" 2>/dev/null; then
      say "removed $p"
      continue
    fi
    # Retry once after a brief wait — sometimes a process is mid-shutdown.
    sleep 1
    if rm -rf "$p" 2>/dev/null; then
      say "removed $p (after retry)"
      continue
    fi
    # Real failure — record + report so the final message tells the truth.
    PURGE_FAILED=1
    FAILED_PATHS="${FAILED_PATHS}|$p"
    say "⚠ couldn't fully remove $p"
    # Surface the precise error for the user.
    rm -rf "$p" 2>&1 | sed 's/^/    /' || true
  done

  # Drop the cached preferences from cfprefsd so a reinstall doesn't
  # resurrect them from memory. Best-effort.
  defaults delete "$APPID" 2>/dev/null || true

  if [ "$PURGE_FAILED" -eq 0 ]; then
    say "done — this Mac is now at a clean-slate state."
  else
    echo
    say "⚠ Purge incomplete — some user data remained:"
    IFS='|' read -ra FAILED_ARR <<< "${FAILED_PATHS#|}"
    for path in "${FAILED_ARR[@]}"; do
      say "    • $path"
    done
    echo
    say "Likely cause: a Tateru-spawned process (e.g. a Next.js dev server"
    say "from a GreenThumb website preview) still has files open. Manual fix:"
    say "    pkill -f tateru ; pkill -f 'next dev'"
    say "    sudo rm -rf \"${FAILED_ARR[0]}\"   # repeat for each path above"
  fi
else
  echo
  say "User data left intact. A reinstall will pick up where you left off."
  say "Run again with --purge for a true clean-slate (wipes projects, APKs, DB, login)."
fi

echo
say "Note: LLM provider API keys you stored in the macOS Keychain are NOT"
say "touched by this script. To remove them: Keychain Access.app → search"
say "'tateru' or 'anthropic' → delete the matching items."
echo
if [ "$PURGE_FAILED" -eq 0 ]; then
  say "✅ ${PRODUCT} uninstalled."
else
  say "✅ ${PRODUCT} APP removed (user-data cleanup incomplete — see above)."
  exit 2
fi
exit 0
