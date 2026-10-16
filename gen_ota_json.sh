#!/bin/bash
# Regenerate <device>.json after a release build.
# Run from the android tree root, cwd of this repo checked out elsewhere:
#   /path/to/ota/gen_ota_json.sh gts7xllite 20261015 /path/to/this/repo
set -euo pipefail
DEVICE="${1:?usage: gen_ota_json.sh <device> <tag> <repo-dir>}"
TAG="${2:?}"
REPO="${3:?}"
OUT="out/target/product/$DEVICE"
ZIP="lineage-21.0-$TAG-UNOFFICIAL-$DEVICE.zip"
[ -f "$OUT/$ZIP" ] || { echo "missing $OUT/$ZIP"; exit 1; }

DATETIME=$(grep -oP '^ro\.build\.date\.utc=\K\d+' "$OUT/system/build.prop")
SIZE=$(stat -c%s "$OUT/$ZIP")
ID=$(sha256sum "$OUT/$ZIP" | cut -d' ' -f1)
URL="https://github.com/Blitzhagen/android_device_samsung_${DEVICE}/releases/download/lineage-21.0-$TAG/$ZIP"

python3 - "$DATETIME" "$ZIP" "$ID" "$SIZE" "$URL" > "$REPO/$DEVICE.json" <<'PY'
import json, sys
dt, fn, sid, size, url = sys.argv[1:6]
print(json.dumps({"response": [{"datetime": int(dt), "filename": fn, "id": sid,
    "romtype": "UNOFFICIAL", "size": int(size), "url": url,
    "version": "21.0"}]}, indent=2))
PY
echo "wrote $REPO/$DEVICE.json for $ZIP"
