#!/usr/bin/env bash
# Mi Box S (MIBOX3) restore script — re-enables every package that debloat.sh disabled
# Reverses all disable-user actions. Reinstall ES must be done manually from Play Store.
# Author: Malek Almutairi (m3m761)
# Usage: ./restore.sh [adb_target_ip]

set -eu
TARGET="${1:-192.168.100.6}:5555"

echo "=== Mi Box Restore — target: $TARGET ==="
adb connect "$TARGET" >/dev/null

enable() {
  local pkg="$1"
  echo "  enable  $pkg"
  adb -s "$TARGET" shell pm enable "$pkg" 2>&1 | tail -1 || true
}

PKGS=(
  # Xiaomi bloat
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
  # Alphonso ACR
  tv.alphonso.alphonso_eula
  # Google bloat
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
  # Keyboards
  com.google.android.apps.inputmethod.hindi
  com.google.android.apps.inputmethod.zhuyin
  com.google.android.inputmethod.japanese
  com.google.android.inputmethod.pinyin
  # Google TV launcher (in case Phase 6 was run)
  com.google.android.tvlauncher
)

for p in "${PKGS[@]}"; do enable "$p"; done

echo
echo "=== Done. Reinstall ES File Explorer manually from Play Store if you want it back. ==="
echo "=== Rebooting Mi Box ==="
sleep 3
adb -s "$TARGET" reboot
