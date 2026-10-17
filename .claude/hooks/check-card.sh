#!/usr/bin/env bash
# PostToolUse(Write|Edit): syntax-check the app script inside DriverCard.html.
# Exit 2 feeds the node error back to Claude; any other file is ignored.
f=$(jq -r '.tool_input.file_path // .tool_response.filePath // empty')
[[ "$(basename -- "$f")" == "DriverCard.html" && -f "$f" ]] || exit 0
tmp=$(mktemp --suffix=.js)
trap 'rm -f "$tmp"' EXIT
python3 -I - "$f" "$tmp" <<'EOF' || { echo "check-card: no <script data-cfasync=\"false\"> app block found in $f" >&2; exit 2; }
import sys
s = open(sys.argv[1], encoding='utf-8').read()
tag = '<script data-cfasync="false">'
i, j = s.rfind(tag), s.rfind('</script>')
if i < 0 or j < i: sys.exit(1)
open(sys.argv[2], 'w', encoding='utf-8').write(s[i + len(tag):j])
EOF
out=$(node --check "$tmp" 2>&1) || { echo "DriverCard.html app script has a syntax error (page would render blank):" >&2; echo "$out" | sed "s#$tmp#app-script#" >&2; exit 2; }
exit 0
