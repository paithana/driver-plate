#!/usr/bin/env bash
# Assemble dist/ for Cloudflare Pages: only the files that should be public.
# Usage: deploy/build.sh   (then deploy/deploy.sh, or `npx wrangler@4 pages deploy dist --project-name driver-card`)
set -euo pipefail
cd "$(dirname "$0")/.."
vendor/fetch.sh >/dev/null
rm -rf dist && mkdir -p dist/vendor
cp DriverCard.html dist/index.html
cp p.html privacy.html sw.js manifest.webmanifest ads.txt deploy/_headers dist/
cp -r icons dist/icons
cp -r vendor/ort vendor/modnet vendor/tesseract vendor/NOTICE.md dist/vendor/
# Pages limit is 25 MiB per file.
big=$(find dist -type f -size +25M); [[ -z "$big" ]] || { echo "too large for Pages: $big" >&2; exit 1; }
echo "dist/: $(find dist -type f | wc -l) files, $(du -sh dist | cut -f1)"
