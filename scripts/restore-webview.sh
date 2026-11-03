#!/system/bin/sh
# Restores the original WebView from /data/local/tmp/webview-orig. Run as root, then reboot.
DIR=/system/app/webview
BAK=/data/local/tmp/webview-orig

fail() { echo "FAIL: $1"; exit 1; }

[ "$(id -u)" = "0" ] || fail "not root"
[ -f "$BAK/webview.apk" ] || fail "backup missing"

mount -o rw,remount /system || fail "remount read-write"
rm -f "$DIR/webview.apk.new"
sync
cp "$BAK/webview.apk" "$DIR/webview.apk.new" || fail "copy apk"
sync
A=$(sha256sum "$BAK/webview.apk" | cut -d' ' -f1)
B=$(sha256sum "$DIR/webview.apk.new" | cut -d' ' -f1)
if [ "$A" != "$B" ]; then rm -f "$DIR/webview.apk.new"; fail "hash mismatch"; fi
chown root:root "$DIR/webview.apk.new" || fail "chown"
chmod 644 "$DIR/webview.apk.new" || fail "chmod"
chcon u:object_r:system_file:s0 "$DIR/webview.apk.new" || fail "chcon"
mv "$DIR/webview.apk.new" "$DIR/webview.apk" || fail "rename"
rm -rf "$DIR/oat"
cp -a "$BAK/oat" "$DIR/oat" || echo "WARN: oat copy failed"
chown -R root:root "$DIR/oat"
chcon -R u:object_r:system_file:s0 "$DIR/oat"
sync
mount -o ro,remount /system || echo "WARN: /system stays read-write until reboot"
ls -lZ "$DIR"
sha256sum "$DIR/webview.apk"
echo RESTORE_OK
