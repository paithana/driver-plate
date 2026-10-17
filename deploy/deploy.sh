#!/usr/bin/env bash
# Build and publish to Cloudflare Pages (project driver-card, production branch main), then verify the live copy.
# Cloudflare strips <!--email_off--> markers (they stop email obfuscation), so the check ignores them.
set -euo pipefail
cd "$(dirname "$0")/.."
deploy/build.sh
npx -y wrangler@4 pages deploy dist --project-name driver-card --branch main --commit-dirty=true
for path in "/:DriverCard.html" "/p:p.html" "/privacy:privacy.html"; do
  url="https://driver.thinkweb.me${path%%:*}"; file="${path#*:}"
  for i in 1 2 3 4 5 6; do curl -s --compressed "$url" | cmp -s - <(sed 's#<!--/\?email_off-->##' "$file") && { echo "live ok  $url"; continue 2; }; sleep 5; done
  echo "live MISMATCH  $url (Pages may still be propagating)" >&2
done
