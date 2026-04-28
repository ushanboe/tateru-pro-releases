# Tateru Pro — Public Release Binaries

This repository hosts the **public release binaries** for Tateru Pro, an AI-driven Android app pipeline. The product source code lives in a separate private repository.

- **Product website:** https://tateru.app
- **Download latest release:** https://github.com/ushanboe/tateru-pro-releases/releases/latest
- **Beta access:** https://tateru.app/beta
- **Support:** support@tateru.app

## What's in each release

| Platform | File | Notes |
|---|---|---|
| Linux x64 | `Tateru Pro-X.Y.Z.AppImage` | Self-contained — `chmod +x && ./Tateru\ Pro-X.Y.Z.AppImage` |
| Linux x64 | `tateru-pro-plus_X.Y.Z_amd64.deb` | `sudo apt install ./tateru-pro-plus_X.Y.Z_amd64.deb` |
| macOS (Intel + Apple Silicon via Rosetta) | `Tateru Pro-X.Y.Z-mac.zip` | Unzip → drag to /Applications. Unsigned during beta — first launch needs right-click → Open. See [MACOS_INSTALL.md](https://github.com/ushanboe/tateru-pro-releases/blob/main/MACOS_INSTALL.md). |
| Windows x64 | `Tateru Pro-X.Y.Z-win.zip` | Unzip → run `Tateru Pro.exe`. SmartScreen "More info → Run anyway" on first launch. |

Every release ships a `SHA256SUMS-<version>` file. Verify with `sha256sum -c SHA256SUMS-<version>`.

## Beta status

Currently in **closed beta**. Use an invite code from the beta access page to register.

Tateru Pro is under active development. Patch releases ship on a roughly daily cadence as bugs surface from beta testers. See [Releases](https://github.com/ushanboe/tateru-pro-releases/releases) for the full history.

## License + privacy

The Tateru Pro app is proprietary software. By downloading and installing, you agree to the [Terms of Use](https://www.tateru.app/terms) and [Privacy Policy](https://www.tateru.app/privacy).
