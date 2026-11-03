#!/system/bin/sh
# Replaces the system WebView by verified rename. Run as root, then reboot.
# Usage: swap-webview.sh <sha256 of /data/local/tmp/webview-new.apk>
WANT="$1"
SRC=/data/local/tmp/webview-new.apk
DIR=/system/app/webview
BAK=/data/local/tmp/webview-orig

fail() { echo "FAIL: $1"; rm -f "$DIR/webview.apk.new"; mount -o ro,remount /system; exit 1; }

[ "$(id -u)" = "0" ] || { echo "FAIL: not root"; exit 1; }
[ -n "$WANT" ] || { echo "FAIL: expected SHA-256 argument"; exit 1; }
[ -f "$BAK/webview.apk" ] && [ -d "$BAK/oat" ] || { echo "FAIL: original WebView backup missing"; exit 1; }
[ "$(sha256sum "$SRC" | cut -d' ' -f1)" = "$WANT" ] || { echo "FAIL: source hash"; exit 1; }

mount -o rw,remount /system || fail "remount read-write"
# Keep the current APK until the new one is complete and verified.
cp "$SRC" "$DIR/webview.apk.new" || fail "copy"
sync
[ "$(sha256sum "$DIR/webview.apk.new" | cut -d' ' -f1)" = "$WANT" ] || fail "copied hash"
chown root:root "$DIR/webview.apk.new" || fail "chown"
chmod 644 "$DIR/webview.apk.new" || fail "chmod"
chcon u:object_r:system_file:s0 "$DIR/webview.apk.new" || fail "chcon"
mv "$DIR/webview.apk.new" "$DIR/webview.apk" || fail "rename"
rm -rf "$DIR/oat"
sync
mount -o ro,remount /system || echo "WARN: /system stays read-write until reboot"
ls -lZ "$DIR"
sha256sum "$DIR/webview.apk"
echo SWAP_OK
