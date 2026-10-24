#!/usr/bin/env bash
# Mi Box S (MIBOX3) personal debloat script
# Author: Malek Almutairi (m3m761)
# Target: Xiaomi Mi Box S / MIBOX3 / Android 9
# Date: 2026-10-24
#
# Prerequisites:
#   - adb installed (brew install android-platform-tools)
#   - ADB debugging enabled on the Mi Box
#   - Mi Box reachable on LAN (default 192.168.100.6)
#
# Usage:  ./debloat.sh [adb_target_ip]
# Example: ./debloat.sh 192.168.100.6
#
# All actions are REVERSIBLE via ./restore.sh

set -eu

TARGET="${1:-192.168.100.6}:5555"

echo "=== Mi Box Debloat — target: $TARGET ==="
adb connect "$TARGET" >/dev/null

disable() {
  local pkg="$1"
  echo "  disable  $pkg"
  adb -s "$TARGET" shell pm disable-user --user 0 "$pkg" 2>&1 | tail -1 || true
}

uninstall() {
  local pkg="$1"
  echo "  uninstall $pkg"
  adb -s "$TARGET" shell pm uninstall --user 0 "$pkg" 2>&1 || true
}

# --- Phase 1: Uninstall known-bad app ---
echo
echo "--- Uninstalling ES File Explorer (known ad-fraud / spyware history) ---"
uninstall com.estrongs.android.pop

# --- Phase 2: Xiaomi bloat ---
echo
echo "--- Disabling Xiaomi bloat ---"
XIAOMI_BLOAT=(
  com.miui.tv.analytics
  com.xiaomi.mitv.updateservice
  com.mitv.tvhome.atv
  com.mitv.tvhome.michannel
  com.mitv.download.service
  com.mitv.milinkservice
  com.mitv.videoplayer
  com.xm.webcontent
  mitv.service
  com.xiaomi.mitv.res
  com.xiaomi.android.tvsetup.partnercustomizer
  android.autoinstalls.config.xioami.mibox3
)
for p in "${XIAOMI_BLOAT[@]}"; do disable "$p"; done

# --- Phase 3: Alphonso ACR (automatic content recognition — privacy critical) ---
echo
echo "--- Disabling Alphonso ACR (watches what you watch) ---"
disable tv.alphonso.alphonso_eula

# --- Phase 4: Google bloat (not strictly needed on this device) ---
echo
echo "--- Disabling unused Google services ---"
GOOGLE_BLOAT=(
  com.google.android.backdrop
  com.google.android.tvrecommendations
  com.google.android.katniss
  com.google.android.youtube.tvmusic
  com.google.android.videos
  com.google.android.play.games
  com.google.android.feedback
  com.google.android.partnersetup
  com.google.android.onetimeinitializer
  com.android.onetimeinitializer
  com.google.android.sss.authbridge
  com.google.android.syncadapters.calendar
  com.google.android.syncadapters.contacts
  com.google.android.tv.bugreportsender
  com.google.android.tungsten.setupwraith
)
for p in "${GOOGLE_BLOAT[@]}"; do disable "$p"; done

# --- Phase 5: Language keyboards (non-English) ---
echo
echo "--- Disabling non-English keyboards ---"
KEYBOARDS=(
  com.google.android.apps.inputmethod.hindi
  com.google.android.apps.inputmethod.zhuyin
  com.google.android.inputmethod.japanese
  com.google.android.inputmethod.pinyin
)
for p in "${KEYBOARDS[@]}"; do disable "$p"; done

# --- Phase 6: Launcher swap (requires Projectivy installed first) ---
# Projectivy install options:
#   A) Via Play Store on TV:
#        adb shell am start -a android.intent.action.VIEW -d "market://details?id=com.spocky.projengmenu"
#   B) Via Aptoide direct APK (requires curl):
#        curl -sfL -o Projectivy.apk \
#          "https://pool.apk.aptoide.com/appstv/com-spocky-projengmenu-82-71602658-b1c45b01481b80ea9435bfb774316405.apk"
#        adb -s "$TARGET" install -r Projectivy.apk
#
# Alternative (open-source) launcher: LtvLauncher — install via:
#   curl -sfL -o LTvLauncher.apk \
#     "https://github.com/leanbitlab-org/LtvLauncher/releases/download/v2026.10.03/LTvLauncher-armeabi-v7a-release.apk"
#   adb -s "$TARGET" install -r LTvLauncher.apk
#
# Then:
echo
echo "--- Replacing Google TV launcher with Projectivy ---"
if adb -s "$TARGET" shell pm list packages com.spocky.projengmenu 2>&1 | grep -q projengmenu; then
  adb -s "$TARGET" shell cmd package set-home-activity com.spocky.projengmenu/.ui.home.MainActivity
  disable com.google.android.tvlauncher
  echo "  Projectivy set as default home, Google TV launcher disabled."
else
  echo "  Projectivy not installed — skipping launcher swap. Install it first (see Phase 6 instructions)."
fi

echo
echo "=== Done. Rebooting Mi Box to apply changes ==="
echo "(Press Ctrl+C within 5 seconds to skip reboot.)"
sleep 5
adb -s "$TARGET" reboot
