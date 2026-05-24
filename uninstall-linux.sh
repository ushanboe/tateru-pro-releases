#!/usr/bin/env bash
# Tateru Pro — clean Linux uninstaller (end-user script).
#
# Removes BOTH install methods so a fresh install can't get confused about
# version number or which copy the Apps-menu launches:
#   - the .deb package (/opt/Tateru Pro/, /usr/bin symlink, AppArmor profile,
#     system .desktop + icons) — removed via dpkg, which runs deb-postrm.sh
#   - the AppImage's self-integration artifacts (mod 10.159): the per-user
#     .desktop entry + hicolor icons it writes on first launch
#   - any orphaned system files left behind by a partial/failed removal
#
# By default it preserves your data (generated projects, built APKs, SQLite
# DB, Cloud login) so you can reinstall without losing work. Pass --purge to
# also wipe that.
#
# This is NOT scripts/uninstall.sh — that one reverses the dev `setup.sh`
# (npm install, Prisma, venv). This one removes an *installed* Tateru Pro.
#
# Usage:
#   ./uninstall-linux.sh            # interactive — asks keep/wipe/cancel
#   ./uninstall-linux.sh --purge    # also delete projects/APKs/DB/login
#   ./uninstall-linux.sh --yes      # don't prompt for confirmation (keeps data)
#   ./uninstall-linux.sh --yes --purge   # wipe everything, no prompts
#   ./uninstall-linux.sh --help
#
# One-liner (must use process substitution to preserve interactive stdin):
#   bash <(curl -fsSL https://tateru.app/uninstall-linux.sh)
#
# DON'T pipe via curl | bash — that hands curl's stdout to the script as
# stdin, breaking the interactive keep/wipe prompt. The script detects this
# and refuses to guess, printing the correct invocation instead.
#
# Best-effort throughout — every fallible step continues on error, like the
# .deb maintainer scripts. Needs sudo only if a .deb is actually installed.

set -u

PKG="tateru-pro-plus"
PRODUCT="Tateru Pro"
PURGE=0
ASSUME_YES=0

for arg in "$@"; do
  case "$arg" in
    --purge) PURGE=1 ;;
    --yes|-y) ASSUME_YES=1 ;;
    --help|-h)
      sed -n '2,30p' "$0" | sed 's/^# \{0,1\}//'
      exit 0 ;;
    *) echo "Unknown option: $arg (try --help)" >&2; exit 1 ;;
  esac
done

say()  { printf '  %s\n' "$*"; }
head() { printf '\n=== %s ===\n' "$*"; }

# ----------------------------------------------------------------------
# Discover what's present
# ----------------------------------------------------------------------
DEB_INSTALLED=0
if command -v dpkg >/dev/null 2>&1 && dpkg -s "$PKG" >/dev/null 2>&1; then
  DEB_INSTALLED=1
fi

USER_DESKTOP="$HOME/.local/share/applications/${PKG}.desktop"
USER_ICONS_GLOB="$HOME/.local/share/icons/hicolor/*/apps/${PKG}.png"
APPIMAGE_INTEGRATED=0
[ -f "$USER_DESKTOP" ] && APPIMAGE_INTEGRATED=1

# AppImage binaries the user may have downloaded — common locations only.
# We never delete these without asking; renaming/moving an AppImage is the
# user's call.
FOUND_APPIMAGES=()
for d in "$HOME/Downloads" "$HOME/Applications" "$HOME/.local/bin" "$HOME/bin" "$HOME/Desktop" "$PWD"; do
  [ -d "$d" ] || continue
  while IFS= read -r -d '' f; do FOUND_APPIMAGES+=("$f"); done \
    < <(find "$d" -maxdepth 1 -iname 'Tateru*Pro*.AppImage' -print0 2>/dev/null)
done

head "What was found"
[ "$DEB_INSTALLED" -eq 1 ] && say "✓ .deb package installed: $PKG ($(dpkg-query -W -f='${Version}' "$PKG" 2>/dev/null))" \
                            || say "· .deb package: not installed"
[ "$APPIMAGE_INTEGRATED" -eq 1 ] && say "✓ AppImage self-integration: $USER_DESKTOP" \
                                 || say "· AppImage self-integration: none"
[ -e /etc/apparmor.d/${PKG} ] && say "✓ AppArmor profile: /etc/apparmor.d/${PKG}"
[ -e "/opt/${PRODUCT}" ]      && say "✓ App directory: /opt/${PRODUCT}"
[ -L "/usr/bin/${PKG}" ]      && say "✓ CLI symlink: /usr/bin/${PKG}"
if [ "${#FOUND_APPIMAGES[@]}" -gt 0 ]; then
  say "✓ AppImage file(s) on disk:"
  for f in "${FOUND_APPIMAGES[@]}"; do say "    $f"; done
fi

# User data — reported so the user knows what --purge would remove.
DATA_DIRS=(
  "$HOME/.config/${PKG}"
  "$HOME/.cache/${PKG}"
  "$HOME/.cache/${PKG}-updater"
  "$HOME/.tateru-pro"
)
head "User data (kept unless --purge)"
for d in "${DATA_DIRS[@]}"; do
  [ -e "$d" ] && say "• $d ($(du -sh "$d" 2>/dev/null | cut -f1))"
done

if [ "$DEB_INSTALLED" -eq 0 ] && [ "$APPIMAGE_INTEGRATED" -eq 0 ] \
   && [ ! -e "/opt/${PRODUCT}" ] && [ ! -e /etc/apparmor.d/${PKG} ] \
   && [ ! -L "/usr/bin/${PKG}" ]; then
  echo
  say "Nothing to uninstall — no .deb, no AppImage integration, no leftovers."
  [ "$PURGE" -eq 1 ] && say "(--purge can still remove the user-data dirs listed above.)"
  [ "$PURGE" -eq 0 ] && exit 0
fi

# ----------------------------------------------------------------------
# Interactive mode selection (one-liner UX)
# ----------------------------------------------------------------------
# Behaviour:
#   --yes alone           → no prompts, current PURGE value used (0 by default)
#   --purge alone         → asks proceed-yes/no, mode is wipe
#   --yes --purge         → no prompts, full purge
#   neither, TTY stdin    → ask "keep data / wipe data / cancel" THEN final
#                            proceed prompt (current behaviour preserved)
#   neither, no TTY       → safe-default: print guidance + abort
#                            (prevents accidental data loss from "curl | bash"
#                            invocation which can't accept interactive input)
#
# The bash <(curl -fsSL ...) invocation form keeps stdin connected to the
# terminal so the prompts work. "curl | bash" gives the script curl's
# stdout as stdin, breaking read — caught by the no-TTY branch below.

if [ "$ASSUME_YES" -eq 0 ] && [ "$PURGE" -eq 0 ]; then
  if [ -t 0 ]; then
    echo
    echo "You're about to uninstall Tateru Pro. Two options for your data:"
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
    # Non-interactive (probably piped via "curl | bash" instead of "bash <(curl ...)").
    # Refuse to guess about data — print guidance + abort.
    echo
    echo "❌ Uninstaller can't ask about your data because stdin isn't a terminal."
    echo
    echo "   You probably ran:   curl ... | bash"
    echo "   Use this instead:   bash <(curl -fsSL https://tateru.app/uninstall-linux.sh)"
    echo
    echo "   Or pass flags explicitly:"
    echo "     curl ... | bash -s -- --yes              # keep data, no prompts"
    echo "     curl ... | bash -s -- --yes --purge      # wipe data, no prompts"
    exit 1
  fi
fi

# ----------------------------------------------------------------------
# Confirm
# ----------------------------------------------------------------------
echo
if [ "$PURGE" -eq 1 ]; then
  say "MODE: full removal + PURGE — app AND all user data above will be deleted."
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
# 1. Remove the .deb package (runs deb-postrm.sh → AppArmor + symlink cleanup)
# ----------------------------------------------------------------------
if [ "$DEB_INSTALLED" -eq 1 ]; then
  head "Removing .deb package"
  if [ "$PURGE" -eq 1 ]; then
    sudo dpkg --purge "$PKG" || sudo apt-get purge -y "$PKG" || say "⚠ dpkg purge failed — see output above"
  else
    sudo dpkg -r "$PKG" || sudo apt-get remove -y "$PKG" || say "⚠ dpkg remove failed — see output above"
  fi
  say "done"
fi

# ----------------------------------------------------------------------
# 2. Remove AppImage self-integration artifacts (mod 10.159)
# ----------------------------------------------------------------------
head "Removing AppImage integration artifacts"
if [ -f "$USER_DESKTOP" ]; then
  rm -f "$USER_DESKTOP" && say "removed $USER_DESKTOP"
fi
ICONS_REMOVED=0
for icon in $USER_ICONS_GLOB; do
  [ -e "$icon" ] || continue
  rm -f "$icon" && ICONS_REMOVED=$((ICONS_REMOVED + 1))
done
[ "$ICONS_REMOVED" -gt 0 ] && say "removed $ICONS_REMOVED per-user icon file(s)"
# Refresh caches so the Apps menu drops the stale entry immediately.
command -v update-desktop-database >/dev/null 2>&1 \
  && update-desktop-database -q "$HOME/.local/share/applications" 2>/dev/null
command -v gtk-update-icon-cache >/dev/null 2>&1 \
  && gtk-update-icon-cache --quiet --force "$HOME/.local/share/icons/hicolor" 2>/dev/null
say "done"

# ----------------------------------------------------------------------
# 3. Sweep orphaned system files (partial/failed removals, old packages)
# ----------------------------------------------------------------------
head "Sweeping orphaned system files"
ORPHANS=()
[ -e /etc/apparmor.d/${PKG} ]      && ORPHANS+=("/etc/apparmor.d/${PKG}")
[ -L "/usr/bin/${PKG}" ]           && ORPHANS+=("/usr/bin/${PKG}")
[ -e /etc/alternatives/${PKG} ]    && ORPHANS+=("/etc/alternatives/${PKG}")
[ -d "/opt/${PRODUCT}" ]           && ORPHANS+=("/opt/${PRODUCT}")
if [ "${#ORPHANS[@]}" -gt 0 ]; then
  # AppArmor profile must be unloaded from the kernel before the file is removed.
  if [ -e /etc/apparmor.d/${PKG} ] && command -v apparmor_parser >/dev/null 2>&1; then
    sudo apparmor_parser -R /etc/apparmor.d/${PKG} 2>/dev/null || true
  fi
  for o in "${ORPHANS[@]}"; do
    sudo rm -rf "$o" && say "removed $o"
  done
else
  say "none — clean"
fi

# ----------------------------------------------------------------------
# 4. AppImage binaries on disk — list, remove only with --yes
# ----------------------------------------------------------------------
if [ "${#FOUND_APPIMAGES[@]}" -gt 0 ]; then
  head "AppImage binaries"
  for f in "${FOUND_APPIMAGES[@]}"; do
    if [ "$ASSUME_YES" -eq 1 ]; then
      rm -f "$f" && say "removed $f"
    else
      printf '  Delete %s ? [y/N] ' "$f"
      read -r r
      case "$r" in y|Y|yes|YES) rm -f "$f" && say "  removed";; *) say "  kept";; esac
    fi
  done
fi

# ----------------------------------------------------------------------
# 5. Purge user data (only with --purge)
# ----------------------------------------------------------------------
if [ "$PURGE" -eq 1 ]; then
  head "Purging user data"
  for d in "${DATA_DIRS[@]}"; do
    [ -e "$d" ] || continue
    rm -rf "$d" && say "removed $d"
  done
  say "done — this machine is now at a clean-slate state."
else
  echo
  say "User data left intact. A reinstall will pick up where you left off."
  say "Run again with --purge for a true clean-slate (wipes projects, APKs, DB, login)."
fi

echo
say "✅ Tateru Pro uninstalled. You can now install a single method cleanly."
exit 0
