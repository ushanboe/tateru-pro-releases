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
#   ./uninstall-macos.sh            # quit + remove the .app, keep user data
#   ./uninstall-macos.sh --purge    # also delete projects/APKs/DB/login/caches
#   ./uninstall-macos.sh --yes      # don't prompt for confirmation
#   ./uninstall-macos.sh --help
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

echo
if [ "$PURGE" -eq 1 ]; then
  say "MODE: full removal + PURGE — the app AND all user data above will be deleted."
else
  say "MODE: app removal only — user data above is PRESERVED (run with --purge to wipe it)."
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
if [ "$PURGE" -eq 1 ]; then
  head "Purging user data"
  for p in "${DATA_PATHS[@]}"; do
    [ -e "$p" ] || continue
    rm -rf "$p" && say "removed $p"
  done
  # Drop the cached preferences from cfprefsd so a reinstall doesn't
  # resurrect them from memory.
  defaults delete "$APPID" 2>/dev/null || true
  say "done — this Mac is now at a clean-slate state."
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
say "✅ ${PRODUCT} uninstalled."
exit 0
