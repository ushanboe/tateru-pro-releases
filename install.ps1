# Tateru Pro — one-line installer for Windows (PowerShell).
#
# Usage:
#   irm https://tateru.app/install.ps1 | iex
#   irm https://raw.githubusercontent.com/ushanboe/tateru-pro-releases/main/install.ps1 | iex
#
# Review-first (recommended for security-conscious users):
#   irm https://tateru.app/install.ps1 -OutFile install.ps1
#   notepad install.ps1                      # inspect before running
#   powershell -ExecutionPolicy Bypass -File install.ps1
#
# Flags (supported only when running as a downloaded file, not via | iex):
#   -NoLaunch        Don't auto-launch the app after install
#   -Version <X>     Install a specific version (default: latest)
#   -Silent          Pass /S to the NSIS installer (no UI; still triggers SmartScreen first time)
#
# What this script does:
#   1. Queries the GitHub Releases API for the latest tag
#   2. Downloads the NSIS .exe installer to %TEMP%
#   3. Runs the installer (per-user, no admin required)
#   4. Optionally launches the app after install completes
#
# Tateru is currently UNSIGNED on Windows. Windows SmartScreen will show
# 'Windows protected your PC' on first launch of the downloaded .exe.
# Click 'More info' → 'Run anyway' to proceed. Azure Trusted Signing is
# planned post-beta to eliminate this warning.

param(
  [switch]$NoLaunch,
  [string]$Version = '',
  [switch]$Silent
)

$ErrorActionPreference = 'Stop'
$repo = 'ushanboe/tateru-pro-releases'

function Write-Info($msg) { Write-Host "ℹ  $msg" -ForegroundColor Cyan }
function Write-Ok($msg)   { Write-Host "✓ $msg" -ForegroundColor Green }
function Write-Warn($msg) { Write-Host "⚠  $msg" -ForegroundColor Yellow }
function Write-Fail($msg) { Write-Host "❌ $msg" -ForegroundColor Red; exit 1 }

# Force TLS 1.2 — older PowerShell defaults to TLS 1.0 which GitHub rejects.
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# ── resolve version ─────────────────────────────────────────────────
if ($Version) {
  $resolvedVersion = $Version -replace '^v',''
  Write-Info "Installing pinned version: $resolvedVersion"
} else {
  Write-Info "Fetching latest release info from GitHub..."
  try {
    $latestRelease = Invoke-RestMethod -Uri "https://api.github.com/repos/$repo/releases/latest" -UseBasicParsing
  } catch {
    Write-Fail "Couldn't reach GitHub Releases API. Network down? Error: $($_.Exception.Message)"
  }
  $resolvedVersion = $latestRelease.tag_name -replace '^v',''
  if (-not $resolvedVersion) { Write-Fail "Couldn't parse latest version from GitHub response." }
  Write-Ok "Latest version: $resolvedVersion"
}

# ── download NSIS installer ──────────────────────────────────────────
# GitHub release upload replaces spaces with dots in asset names —
# "Tateru Pro Setup X.Y.Z.exe" becomes "Tateru.Pro.Setup.X.Y.Z.exe".
# Use the dotted form for the URL; keep a friendly display name for
# the local %TEMP% file so users see the readable filename.
$asset = "Tateru.Pro.Setup.$resolvedVersion.exe"
$displayName = "Tateru Pro Setup $resolvedVersion.exe"
$downloadUrl = "https://github.com/$repo/releases/download/v$resolvedVersion/$asset"
$tmpInstaller = Join-Path $env:TEMP $displayName

Write-Info "Downloading $asset (~171 MB) to %TEMP%..."
try {
  Invoke-WebRequest -Uri $downloadUrl -OutFile $tmpInstaller -UseBasicParsing
} catch {
  Write-Fail "Download failed: $($_.Exception.Message)`n  URL: $downloadUrl"
}
Write-Ok "Downloaded to $tmpInstaller"

# ── run installer ────────────────────────────────────────────────────
Write-Host ""
Write-Host "─────────────────────────────────────────────────────────────" -ForegroundColor DarkGray
Write-Warn "Windows SmartScreen may show 'Windows protected your PC'"
Write-Warn "  → Click 'More info' → 'Run anyway' to continue."
Write-Warn "  (Tateru is unsigned during beta. Code signing via Azure"
Write-Warn "   Trusted Signing is on the post-beta roadmap.)"
Write-Host "─────────────────────────────────────────────────────────────" -ForegroundColor DarkGray
Write-Host ""

Write-Info "Running installer (per-user — no admin required)..."
if ($Silent) {
  # /S = NSIS silent install. SmartScreen still gates the first run if MOTW present.
  Start-Process -FilePath $tmpInstaller -ArgumentList '/S' -Wait
} else {
  Start-Process -FilePath $tmpInstaller -Wait
}
Write-Ok "Installation complete."

# Cleanup: best-effort. Windows may have the file briefly locked.
try { Remove-Item $tmpInstaller -Force -ErrorAction SilentlyContinue } catch {}

# ── post-install launch ──────────────────────────────────────────────
if (-not $NoLaunch) {
  # NSIS perMachine:false installs to %LOCALAPPDATA%\Programs\Tateru Pro\Tateru Pro.exe
  $exePath = Join-Path $env:LOCALAPPDATA 'Programs\Tateru Pro\Tateru Pro.exe'
  if (Test-Path $exePath) {
    Write-Info "Launching Tateru Pro..."
    Start-Process -FilePath $exePath
  } else {
    Write-Info "Installation finished — find Tateru Pro in your Start Menu."
  }
}

Write-Host ""
Write-Host "─────────────────────────────────────────────────────────────"
Write-Host "  Tateru Pro v$resolvedVersion installed."
Write-Host ""
Write-Host "  First launch sets up your data dir at"
Write-Host "  %APPDATA%\tateru-pro-plus."
Write-Host ""
Write-Host "  Quick Start:  https://tateru.app/quick-start"
Write-Host "  Privacy:      https://tateru.app/privacy"
Write-Host "─────────────────────────────────────────────────────────────"
