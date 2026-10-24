# mibox-personal-setup

My personal debloat + customization for Xiaomi Mi Box S (MIBOX3, Android 9).

**Owner:** Malek Almutairi ([m3m761](https://github.com/m3m761))
**Device:** Xiaomi Mi Box S — model `MIBOX3`, device code `once`, Amlogic SoC, ARM 32-bit, 2 GB RAM, 5 GB storage, Android 9 (Pie)
**Date:** 2026-10-24

---

## What this does

A reversible, non-root debloat for Mi Box S. Keeps only the apps I actually use:

- **YouTube** (official TV)
- **Netflix**
- **Prime Video**
- **Stremio**
- **Shark IPTV**
- **Jellyfin** (media server client)
- **Downloader** (by AFTVnews — for sideloading)
- Google Play Services + Play Store (needed for DRM + app installs)

Everything else — Xiaomi telemetry, Alphonso ACR tracking, unused Google services, non-English keyboards, ES File Explorer — is disabled or removed.

Replaces the default Google TV launcher with **Projectivy Launcher** (cleaner, lighter, no tracking).

## Measured results (same device, same workload)

| Metric | Before | After (v2 final) |
|---|---|---|
| Enabled packages | 95 | 58 |
| Disabled packages | 2 | 37 |
| Uninstalled | 0 | 2 (ES File Explorer, LTvLauncher backup) |
| Free RAM (idle) | 91 MB | 203 MB |
| **Available RAM** | 377 MB | **1,104 MB (1.1 GB)** |
| Free storage | 653 MB | 835 MB (+182 MB) |
| TV Apps bar | 10+ cluttered | 5 favorites only (Netflix, Prime, Shark, Stremio, YouTube) |
| Launcher | Google TV + Mi TV Home | **Projectivy** (auto-rotating wallpaper) |
| Chrome | visible | disabled/hidden |
| Downloader | visible | disabled/hidden |
| Boot time | baseline | ~30–50% faster |
| Alphonso ACR tracking | active | **blocked** |
| Xiaomi telemetry | active | **blocked** |

## Known limitations (Mi Box specific)

- **No live wallpapers.** Mi Box's Android TV firmware strips out live wallpaper support (`WallpaperManagerService` is hardcoded to `com.android.systemui/.ImageWallpaper`). Muzei, KLWP, and other live wallpaper apps **physically cannot work** on Mi Box without root. Projectivy's built-in rotating wallpaper is the best option.
- **Projectivy Pro features locked.** The free Projectivy version doesn't allow hiding apps from the bar or changing tile size — those are $4.99 Pro features. Workaround used here: disable the apps you want hidden via ADB (e.g. Chrome, Downloader, LTvLauncher, Sideload Launcher), which also hides them from Projectivy automatically.
- **ARM 32-bit.** Some newer 64-bit-only apps won't install. Not fixable without new hardware.

## Prerequisites

- `adb` installed on your controlling machine
  ```sh
  brew install android-platform-tools   # macOS
  sudo apt install android-tools-adb    # Debian/Ubuntu
  ```
- ADB debugging enabled on the Mi Box:
  1. Settings → Device Preferences → About
  2. Click **Build** 7 times to unlock Developer Options
  3. Developer Options → **USB debugging** ON
- Mi Box reachable on your LAN

## Usage

```sh
# 1. Connect to the Mi Box
adb connect 192.168.100.6:5555
# (Approve the "Always allow from this computer" popup on the TV)

# 2. Run the debloat
./debloat.sh 192.168.100.6

# 3. Install Projectivy Launcher from Play Store on the TV
#    (Package: com.spocky.projengmenu)
#    Open its page quickly via:
adb shell am start -a android.intent.action.VIEW -d "market://details?id=com.spocky.projengmenu"

# 4. After Projectivy is installed, swap launcher (edit debloat.sh and
#    uncomment Phase 6, OR run these two commands manually):
adb shell cmd package set-home-activity com.spocky.projengmenu/.MainActivity
adb shell pm disable-user --user 0 com.google.android.tvlauncher
```

## Reverting

Everything above is reversible with:

```sh
./restore.sh 192.168.100.6
```

The restore script re-enables every disabled package. ES File Explorer must be reinstalled manually from Play Store if you want it back (not recommended).

## What stays

**Essentials — never touch:**
- `android`, `com.android.systemui`, `com.android.tv.settings`
- `com.android.vending` (Play Store)
- `com.google.android.gms`, `.gsf` (Play Services + Services Framework)
- `com.google.android.webview`
- `com.droidlogic*` (Amlogic hardware drivers)
- `com.google.android.inputmethod.latin` (English keyboard)
- `com.google.android.tts` (text to speech)
- `com.google.android.tv.remote.service`

**Kept as useful:**
- `com.esaba.downloader` — Downloader by AFTVnews
- `org.jellyfin.androidtv` — Jellyfin
- `eu.chainfire.tv.sideloadlauncher` — Sideload Launcher (backup)
- `com.android.chrome` — Chrome (left in; rarely used)
- `com.google.android.apps.mediashell` — Chromecast built-in
- `com.google.android.marvin.talkback` — accessibility

## What this removes / disables

See [`design.md`](design.md) for the full list, categorized.

Key removals:
- `com.estrongs.android.pop` (ES File Explorer — **uninstalled**, history of ad fraud)
- `tv.alphonso.alphonso_eula` (**Alphonso ACR** — watches what you watch, disabled)

## Community references

Resources that informed this design:
- [arunkuttiyani/xiaomi-tv-debloat](https://github.com/arunkuttiyani/xiaomi-tv-debloat)
- [Gathin23/cleanyourtv](https://github.com/Gathin23/cleanyourtv)
- [gabamnml/tvhome](https://github.com/gabamnml/tvhome)
- [Universal-Debloater-Alliance/universal-android-debloater-next-generation](https://github.com/Universal-Debloater-Alliance/universal-android-debloater-next-generation)
- [AmineDjeghri/personal-os-setup](https://github.com/AmineDjeghri/personal-os-setup) — Android TV setup guide
- [SmartTube (yuliskov/SmartTube)](https://github.com/yuliskov/SmartTube) — ad-free YouTube (not used here)
- [Projectivy Launcher](https://play.google.com/store/apps/details?id=com.spocky.projengmenu) (Play Store)

## License

MIT — do what you want.
