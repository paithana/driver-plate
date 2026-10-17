# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

`DriverCard.html` is the whole app: a single self-contained page (Thai UI) that lets a driver fill in their details, add a photo, preview the driver-information placard on a `<canvas>`, and export a 300 dpi JPEG / print A4–A5 landscape. React 18 UMD, every font (base64 woff2) and all CSS/JS are inlined. No build, no package manager, no tests. `DriverCard.orig.html` is the pre-refine backup (it contains a real driver's data — never publish it).

## Working with the file

- It is ~730 KB with 20–30 KB base64 lines. `Read` on the whole file fails; even 50 lines can blow the token cap. Get a skeleton first:
  `awk '{ if (length($0) > 300) print NR": [LONG "length($0)"]"; else print NR": "$0 }' DriverCard.html`
- Layout of the file: `:root` theme tokens → `@font-face` lines (long) → UI stylesheet (type/spacing tokens `--s1…--s7`, `--t-*`) → React + ReactDOM bundles → the app script (last `<script>` block, `h = React.createElement`, no JSX).
- Prefer anchored replacements (Python `str.replace` asserting the anchor occurs exactly once) or `Edit` on lines you've read with `offset`/`limit`.
- Syntax-check the app script after edits (a hook does this automatically):
  `python3 -c "s=open('DriverCard.html',encoding='utf-8').read();i=s.rfind('<script data-cfasync=\"false\">');print(s[i+29:s.rfind('</script>')])" > /tmp/app.js && node --check /tmp/app.js`

## Rules that aren't obvious

- **Card geometry is fixed.** The `D` object (859 × 607.4 design units) and `D.sizes` / `D.rhythm` were measured from the official placard. UI refinements must not change the rendered card; the font-width reference string in `familyScale` also drives sizing. If you change it, compare the per-family ratios before and after; the current string is within 0.7% of the original on every font. Never put a real person's name or numbers in it.
- **Thai typography:** no `letter-spacing` on Thai text (wrap Latin runs in `.latin` instead), nothing Thai below 13px, body line-height ≥ 1.6. Use the spacing tokens, not ad-hoc px.
- **Privacy:** the page is public. Defaults (`DEFAULTS`) must stay obviously fake (นาย สมชาย ใจดี, ภก.0000/00, 00-0000, no photo). If the draft shape or defaults change, bump `STORAGE_KEY`.
- **Every `<script>` tag needs `data-cfasync="false"`** — Rocket Loader is on for the thinkweb.me zone and otherwise rewrites the scripts, and the CSP blocks its loader → blank page.
- **No third-party requests.** nginx sends a CSP allowing only inline + same-origin scripts (`'wasm-unsafe-eval'` for WebAssembly), same-origin `fetch`, and `data:`/`blob:` images and fonts. Don't add CDN links; vendor assets instead.
- **Background removal** ("ลบพื้นหลัง") lazy-loads onnxruntime-web 1.30.0 (wasm-only, `numThreads = 1` so no COOP/COEP needed) and the int8 MODNet model from `vendor/`, ~9.7 MB gzipped on first click. The binaries are gitignored; `vendor/fetch.sh` downloads them pinned and sha256-checked. Licences are in `vendor/NOTICE.md`. Model I/O: `input` [1,3,H,W] in [-1,1], short edge 512, H/W multiples of 32 → `output` [1,1,H,W] alpha. It doesn't work from `file://` (dynamic import).
- The original photo and cut-out live only in React state (`bgCut`), so "คืนรูปเดิม" (restore original) disappears after a reload. That's deliberate: it avoids storing two photos in localStorage.
- Phones (≤ 860px) dock the preview card sticky at the top; check 375px width for horizontal overflow after layout changes.

## Hosting

Live at https://driver.thinkweb.me/ (public, no Cloudflare Access by choice).
- nginx: `/etc/nginx/sites-available/driver` serves only `/` → `/var/www/driver/index.html` and `/vendor/` (wasm/mjs/onnx types, gzip, 7-day cache). Security headers are set only at server level; locations use `expires` so they inherit them. A location-level `add_header` would silently drop the CSP.
- Tunnel: `kzp-net` ingress entry in `~/.cloudflared/config.yml`; service `cloudflared.service` (restarting it briefly drops the other routes on the same tunnel). The `warp-routing: enabled` validate warning is pre-existing and harmless.
- Deploy with `/deploy-card` (copies the file and verifies the public copy is byte-identical).
