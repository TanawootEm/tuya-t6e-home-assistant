#!/system/bin/sh
# Images the system partition to /data/local/tmp and checks its size.
# Reads the partition only. Run as root. Needs about 2 GB free in /data.
OUT=/data/local/tmp/system.img
DEV=$(readlink -f /dev/block/by-name/system)
NAME=$(basename "$DEV")
[ -b "$DEV" ] || { echo "FAIL: system partition not found"; exit 1; }

SECTORS=$(cat "/sys/class/block/$NAME/size")
EXPECT=$((SECTORS * 512))
echo "partition=$DEV expect_bytes=$EXPECT"
rm -f "$OUT" "$OUT.gz"

dd if="$DEV" of="$OUT" bs=4096 || { echo "FAIL: dd"; exit 2; }
ACTUAL=$(wc -c < "$OUT")
echo "actual_bytes=$ACTUAL"
if [ "$ACTUAL" != "$EXPECT" ]; then echo "FAIL: size mismatch"; exit 3; fi

sha256sum "$OUT"
gzip -1 "$OUT" || { echo "FAIL: gzip"; exit 4; }
chmod 644 "$OUT.gz"
ls -l "$OUT.gz"
sha256sum "$OUT.gz"
echo DONE
