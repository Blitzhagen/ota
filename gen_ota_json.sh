#!/bin/bash
# Regenerate <device>.json after a release build.
# Run from the android tree root, cwd of this repo checked out elsewhere:
#   /path/to/ota/gen_ota_json.sh <device> <version> <tag> <repo-dir>
# e.g.: /path/to/ota/gen_ota_json.sh gts7xllite 23.2 20261025 /path/to/ota
set -euo pipefail
DEVICE="${1:?usage: gen_ota_json.sh <device> <version> <tag> <repo-dir>}"
VERSION="${2:?}"
TAG="${3:?}"
REPO="${4:?}"
OUT="out/target/product/$DEVICE"
ZIP="lineage-$VERSION-$TAG-UNOFFICIAL-$DEVICE.zip"
[ -f "$OUT/$ZIP" ] || { echo "missing $OUT/$ZIP"; exit 1; }

DATETIME=$(grep -oP '^ro\.build\.date\.utc=\K\d+' "$OUT/system/build.prop")
SIZE=$(stat -c%s "$OUT/$ZIP")
ID=$(sha256sum "$OUT/$ZIP" | cut -d' ' -f1)
URL="https://github.com/Blitzhagen/android_device_samsung_${DEVICE}/releases/download/lineage-$VERSION-$TAG/$ZIP"

python3 - "$DATETIME" "$ZIP" "$ID" "$SIZE" "$URL" "$VERSION" > "$REPO/$DEVICE.json" <<'PY'
import json, sys
dt, fn, sid, size, url, ver = sys.argv[1:7]
print(json.dumps({"response": [{"datetime": int(dt), "filename": fn, "id": sid,
    "romtype": "UNOFFICIAL", "size": int(size), "url": url,
    "version": ver}]}, indent=2))
PY
echo "wrote $REPO/$DEVICE.json for $ZIP"
