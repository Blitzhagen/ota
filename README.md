# OTA index

Per-device LineageOS updater JSON, fetched via:

    lineage.updater.uri=https://raw.githubusercontent.com/Blitzhagen/ota/main/{device}.json

`{device}` resolves to `ro.lineage.device` (e.g. `gts7xllite` → `gts7xllite.json`).

Per release:
1. Upload the signed zip as a GitHub release asset on the device repo.
2. From the android tree root: `gen_ota_json.sh <device> <tag> <path-to-this-repo>`
3. Commit + push — the Updater picks it up within minutes.
