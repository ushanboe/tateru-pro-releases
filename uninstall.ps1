# Tateru Pro — clean Windows uninstaller (end-user script).
#
# Mirrors the Linux + macOS uninstaller pattern: detect what's installed,
# show user data sizes, ask whether to keep or wipe data, then remove.
#
# Removes BOTH install methods so a fresh install can't get confused about
# version number or which copy the Start Menu launches:
#   - NSIS installed app (runs %LOCALAPPDATA%\Programs\Tateru Pro\Uninstall Tateru Pro.exe /S)
#   - Portable .zip extraction (rm the win-unpacked folder)
#   - User data dirs (only if user picks "wipe my data")
#
# Usage:
#   # Interactive one-liner — asks keep/wipe/cancel
#   irm https://tateru.app/uninstall.ps1 | iex
#
#   # Or download + run as a file (better for security-conscious users)
#   irm https://tateru.app/uninstall.ps1 -OutFile uninstall.ps1
#   notepad uninstall.ps1                       # inspect before running
#   powershell -ExecutionPolicy Bypass -File uninstall.ps1
#
# Flags (only meaningful when running as a downloaded file, not via | iex):
#   -Yes        Skip all confirmation prompts (keeps user data unless -Purge)
#   -Purge      Also delete user data (projects, APKs, login, caches)
#   -Yes -Purge No prompts, wipes everything
#
# What this script does NOT touch (system-wide developer tools):
#   - Flutter SDK            (typically C:\flutter or %USERPROFILE%\flutter)
#   - Android Studio + SDK   (%LOCALAPPDATA%\Android\Sdk, %LOCALAPPDATA%\Google\AndroidStudio*)
#   - Java JDK               (anywhere installed)
#   - Git, Node.js, npm      (anywhere installed)
#   - Windows Credential Manager LLM API keys (must be removed manually)
#
# It only targets paths Tateru itself wrote to. Your dev environment stays intact.
#
# Best-effort throughout — every fallible step continues on error so a partial
# install doesn't block the rest of the cleanup. Reports honestly at the end
# if any path couldn't be removed.

param(
  [switch]$Yes,
  [switch]$Purge
)

$ErrorActionPreference = 'Continue'  # don't stop on first error; we handle them per-step

# ── helpers ──────────────────────────────────────────────────────────
function Write-Step($msg)  { Write-Host "`n=== $msg ===" -ForegroundColor Cyan }
function Write-Info($msg)  { Write-Host "  $msg" }
function Write-Ok($msg)    { Write-Host "  ✓ $msg" -ForegroundColor Green }
function Write-Warn($msg)  { Write-Host "  ⚠ $msg" -ForegroundColor Yellow }
function Write-Fail($msg)  { Write-Host "  ❌ $msg" -ForegroundColor Red }

# ── paths Tateru writes to (ONLY these get touched) ──────────────────
$AppNSIS     = Join-Path $env:LOCALAPPDATA 'Programs\Tateru Pro\Tateru Pro.exe'
$UninstNSIS  = Join-Path $env:LOCALAPPDATA 'Programs\Tateru Pro\Uninstall Tateru Pro.exe'
$PortableDir = Join-Path $env:LOCALAPPDATA 'Programs\Tateru Pro'
$DataPaths = @(
  (Join-Path $env:APPDATA       'tateru-pro-plus'),        # main userData (DB, projects, APKs, license)
  (Join-Path $env:LOCALAPPDATA  'tateru-pro-plus'),        # Electron caches
  (Join-Path $env:USERPROFILE   '.tateru-pro')             # cloud-client cache (JWT, offline queue)
)

# ── detect what's installed ──────────────────────────────────────────
$NsisInstalled    = Test-Path $UninstNSIS
$PortableOnly     = (Test-Path $AppNSIS) -and (-not $NsisInstalled)
$ExistingDataDirs = $DataPaths | Where-Object { Test-Path $_ }

Write-Step "What was found"
if ($NsisInstalled) {
  Write-Ok "NSIS install: $PortableDir (uninstaller present)"
} elseif ($PortableOnly) {
  Write-Ok "Portable .zip install: $PortableDir"
} else {
  Write-Info "· No installed app found"
}

Write-Step "User data (kept unless you wipe)"
if ($ExistingDataDirs.Count -gt 0) {
  foreach ($d in $ExistingDataDirs) {
    $size = (Get-ChildItem -Path $d -Recurse -Force -ErrorAction SilentlyContinue |
             Measure-Object -Property Length -Sum).Sum
    $sizeLabel = if ($size -gt 1GB) { "{0:N1} GB" -f ($size / 1GB) }
                 elseif ($size -gt 1MB) { "{0:N0} MB" -f ($size / 1MB) }
                 elseif ($size -gt 1KB) { "{0:N0} KB" -f ($size / 1KB) }
                 else { "$size B" }
    Write-Info "• $d ($sizeLabel)"
  }
} else {
  Write-Info "(none found)"
}

if (-not $NsisInstalled -and -not $PortableOnly -and $ExistingDataDirs.Count -eq 0) {
  Write-Host ""
  Write-Ok "Nothing to uninstall — no app and no Tateru data on this machine."
  exit 0
}

# ── interactive keep/wipe/cancel prompt ─────────────────────────────
# Behaviour matrix (mirrors Linux + Mac uninstallers):
#   -Yes alone        → no prompts, current $Purge value used (false by default)
#   -Purge alone      → asks proceed-yes/no, mode is wipe
#   -Yes -Purge       → no prompts, full purge
#   neither, interactive host → 3-option keep/wipe/cancel + final proceed prompt
#   neither, non-interactive  → refuse to guess + print correct invocation
#
# PowerShell's Read-Host uses host I/O (not pipeline stdin), so it works
# correctly when invoked via "irm ... | iex" — unlike bash's `read` which
# fails when piped via curl|bash.

if (-not $Yes -and -not $Purge) {
  if ([Environment]::UserInteractive -and $Host.UI.RawUI) {
    Write-Host ""
    Write-Host "You're about to uninstall Tateru Pro. Two options for your data:"
    Write-Host ""
    Write-Host "  [1] Keep my data  - remove the app, KEEP projects + APKs + DB + Cloud login"
    Write-Host "                     (recommended — reinstall later picks up where you left off)"
    Write-Host "  [2] Wipe my data  - remove app AND all user data listed above"
    Write-Host "                     (clean-slate; cannot be undone)"
    Write-Host "  [3] Cancel        - quit without changing anything"
    Write-Host ""
    Write-Host "  This script will NOT touch your Flutter SDK, Android Studio, Java, Git,"
    Write-Host "  Node.js, or your Windows Credential Manager (LLM API keys). Those are"
    Write-Host "  developer tools — separate from Tateru. To remove them, uninstall each"
    Write-Host "  from Settings -> Apps."
    Write-Host ""
    $choice = Read-Host "Choose [1/2/3] (default: 1)"
    if ([string]::IsNullOrWhiteSpace($choice)) { $choice = '1' }
    switch -Regex ($choice) {
      '^(1|k|keep)$'        { $Purge = $false }
      '^(2|w|wipe|purge)$'  { $Purge = $true  }
      '^(3|c|cancel|q)$'    { Write-Host "Cancelled."; exit 0 }
      default               { Write-Host "Unknown choice '$choice' — aborting for safety."; exit 1 }
    }
  } else {
    # Non-interactive host — refuse to guess about user data.
    Write-Host ""
    Write-Fail "Uninstaller can't ask about your data because this isn't an interactive session."
    Write-Host ""
    Write-Host "   You probably ran it from a script or scheduled task."
    Write-Host "   Pass flags explicitly to be non-interactive:"
    Write-Host ""
    Write-Host "     irm https://tateru.app/uninstall.ps1 -OutFile uninstall.ps1"
    Write-Host "     powershell -ExecutionPolicy Bypass -File uninstall.ps1 -Yes              # keep data"
    Write-Host "     powershell -ExecutionPolicy Bypass -File uninstall.ps1 -Yes -Purge       # wipe data"
    exit 1
  }
}

Write-Host ""
if ($Purge) {
  Write-Info "MODE: full removal + PURGE — the app AND all user data above will be deleted."
} else {
  Write-Info "MODE: app removal only — user data above is PRESERVED."
}

if (-not $Yes) {
  Write-Host ""
  $reply = Read-Host "Proceed? [y/N]"
  if ($reply -notmatch '^(y|yes)$') {
    Write-Host "Aborted."
    exit 0
  }
}

# ── 1. Stop running Tateru processes ────────────────────────────────
Write-Step "Stopping Tateru processes"
# Tateru Pro.exe is the Electron main + sub-processes; both share the name.
Get-Process -Name "Tateru Pro" -ErrorAction SilentlyContinue | ForEach-Object {
  try {
    $_.Kill()
    $_.WaitForExit(3000) | Out-Null
    Write-Info "stopped PID $($_.Id) ($($_.ProcessName))"
  } catch {
    Write-Warn "couldn't stop PID $($_.Id): $($_.Exception.Message)"
  }
}
# Also catch any node processes spawned by Tateru (e.g. GreenThumb's Next.js
# dev server for marketing-site preview, mod 10.183). Filter by command line
# to avoid touching unrelated node processes.
Get-CimInstance Win32_Process -ErrorAction SilentlyContinue |
  Where-Object {
    $_.Name -eq 'node.exe' -and
    ($_.CommandLine -match 'tateru' -or $_.CommandLine -match 'next.*dev' -or $_.CommandLine -match '\.tateru-pro')
  } | ForEach-Object {
    try {
      Stop-Process -Id $_.ProcessId -Force -ErrorAction Stop
      Write-Info "stopped node PID $($_.ProcessId)"
    } catch {
      Write-Warn "couldn't stop node PID $($_.ProcessId): $($_.Exception.Message)"
    }
  }
Start-Sleep -Seconds 1  # let kills propagate so file handles release before rm
Write-Ok "done"

# ── 2. Run the NSIS uninstaller (silent) or remove portable dir ─────
if ($NsisInstalled) {
  Write-Step "Removing the app (via NSIS uninstaller)"
  try {
    # /S = silent mode — no UI, no prompts.
    # Wait for completion so the next step doesn't race with NSIS's own cleanup.
    Start-Process -FilePath $UninstNSIS -ArgumentList '/S' -Wait -ErrorAction Stop
    # Check whether NSIS actually removed itself. If the uninstaller still
    # exists, the silent run may have failed (rare but possible on locked files).
    if (Test-Path $UninstNSIS) {
      Write-Warn "NSIS uninstaller exited but the install dir is still present — trying manual remove"
      Remove-Item -Path $PortableDir -Recurse -Force -ErrorAction SilentlyContinue
    } else {
      Write-Ok "removed via NSIS uninstaller"
    }
  } catch {
    Write-Warn "NSIS uninstaller failed: $($_.Exception.Message) — falling back to manual removal"
    Remove-Item -Path $PortableDir -Recurse -Force -ErrorAction SilentlyContinue
  }
} elseif ($PortableOnly) {
  Write-Step "Removing the portable app folder"
  try {
    Remove-Item -Path $PortableDir -Recurse -Force -ErrorAction Stop
    Write-Ok "removed $PortableDir"
  } catch {
    Write-Fail "couldn't remove $PortableDir : $($_.Exception.Message)"
  }
} else {
  Write-Step "App"
  Write-Info "not installed — skipped"
}

# ── 3. Purge user data (only if user picked Wipe / passed -Purge) ───
$PurgeFailed = $false
$FailedPaths = @()

if ($Purge) {
  Write-Step "Purging user data"
  foreach ($p in $DataPaths) {
    if (-not (Test-Path $p)) { continue }
    try {
      Remove-Item -Path $p -Recurse -Force -ErrorAction Stop
      Write-Ok "removed $p"
      continue
    } catch {
      # Retry once after a brief wait — sometimes a process is mid-shutdown.
      Start-Sleep -Seconds 1
      try {
        Remove-Item -Path $p -Recurse -Force -ErrorAction Stop
        Write-Ok "removed $p (after retry)"
        continue
      } catch {
        $PurgeFailed = $true
        $FailedPaths += $p
        Write-Warn "couldn't fully remove $p"
        Write-Info "    $($_.Exception.Message)"
      }
    }
  }

  if (-not $PurgeFailed) {
    Write-Ok "done — this machine is now at a clean-slate state."
  } else {
    Write-Host ""
    Write-Warn "Purge incomplete — some user data remained:"
    foreach ($fp in $FailedPaths) { Write-Info "    • $fp" }
    Write-Host ""
    Write-Info "Likely cause: a Tateru-spawned process still has files open."
    Write-Info "Manual fix:"
    Write-Info "    Get-Process | Where-Object Name -match 'tateru|node' | Stop-Process -Force"
    Write-Info "    Remove-Item -Recurse -Force '$($FailedPaths[0])'   # repeat for each path above"
  }
} else {
  Write-Host ""
  Write-Info "User data left intact. A reinstall will pick up where you left off."
  Write-Info "Run again with -Purge for a true clean-slate (wipes projects, APKs, DB, login)."
}

# ── 4. Final reminders ──────────────────────────────────────────────
Write-Host ""
Write-Info "Note: LLM provider API keys you stored in the Windows Credential Manager"
Write-Info "are NOT touched by this script. To remove them: open Credential Manager"
Write-Info "(Start -> search 'Credential Manager') -> Windows Credentials -> find entries"
Write-Info "beginning with 'Tateru Pro' or 'tateru-pro-plus' -> Remove."
Write-Host ""
Write-Info "Your developer tools (Flutter, Android Studio, Java, Git, Node) are untouched."
Write-Info "To remove those, uninstall each separately from Settings -> Apps."

Write-Host ""
if (-not $PurgeFailed) {
  Write-Ok "Tateru Pro uninstalled."
  exit 0
} else {
  Write-Ok "Tateru Pro APP removed (user-data cleanup incomplete — see above)."
  exit 2
}
