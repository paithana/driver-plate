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
- **Third-party requests: Google AdSense only.** nginx's CSP allows inline + same-origin scripts (`'wasm-unsafe-eval'` for WebAssembly) plus Google's ad hosts (scripts, frames, `connect`, `https:` images). Don't add other CDNs; vendor assets instead.
- **Ads:** AdSense's own `<head>` tag (with `data-cfasync="false"`; AdSense logs a harmless warning about it) loads on every visit because the site-review crawler looks for it. One display unit (`AdUnit`, slot `7260135730`) renders after the form only after the first JPEG download or print in a browser (`ADS.seenKey` in localStorage). Auto ads must stay off in the AdSense console. `ADS.slot` empty = no unit. Don't add Auto ads or units beside the form or preview: ads must not distract from making the card. Unfilled units hide themselves via `:has(ins[data-ad-status="unfilled"])`. `ads.txt` is served at `/ads.txt`.
- **Background removal** ("ลบพื้นหลัง") lazy-loads onnxruntime-web 1.30.0 (wasm-only, `numThreads = 1` so no COOP/COEP needed) and the int8 MODNet model from `vendor/`, ~9.7 MB gzipped on first click. The binaries are gitignored; `vendor/fetch.sh` downloads them pinned and sha256-checked. Licences are in `vendor/NOTICE.md`. Model I/O: `input` [1,3,H,W] in [-1,1], short edge 512, H/W multiples of 32 → `output` [1,1,H,W] alpha. It doesn't work from `file://` (dynamic import).
- The original photo and cut-out live only in React state (`bgCut`), so "คืนรูปเดิม" (restore original) disappears after a reload. That's deliberate: it avoids storing two photos in localStorage.
- **Font weight** is a 400–900 slider, but only 400/700 faces exist. Other weights outline the glyphs in the fill colour (`embolden` in `drawRuns`). `boldStroke(fam)` calibrates the outline per font so the 400 face matches the real 700 face's ink, which keeps the steps even. The Impact digits (`NUM_FONT`) are never outlined.
- **Tourist QR** (`st.qr`, on by default): `qrUrl()` packs `1|nameEn|licenseNo|regNo|provinceEn` as base64url into the fragment of `/p#…` (served from `p.html`), so the details never reach the server. Keep the format in sync with `decode()` in `p.html`, and bump the leading `1` if it changes. The QR is drawn at `D.qr` (96 units, ~23 mm on A5); the payload is a version-6 code that decodes from a 620-px-wide photo of the whole card, so don't make it longer without re-testing. `p.html` has hand-written translations of safety text for 11 languages: never machine-translate it.
- `PROVINCES` (77 Thai → English) is used by the QR and by OCR province matching.
- **Licence OCR** ("ถ่ายรูปใบอนุญาต"/"อัปโหลดรูป"): Tesseract.js 7 (`tha`+`eng` best_int) lazy-loads from `vendor/tesseract/` (~5.6 MB on first scan), with `workerBlobURL: false` so the worker is same-origin under the CSP. `parseLicence()` extracts the Thai name (นาย/นาง/นางสาว/น.ส.), the English name (MR/MRS/MISS/MS, tolerating `,` for `.`), the licence no. (`ภก.0227/67` style first, else an 8-digit number; never the 13-digit citizen ID) and the province. Results go to a review panel; nothing is applied without a tap, and the province starts unticked because it's the issuing office, not the plate's province. Test with fictional licences only.
- **Phones:** focusing a text field adds `.typing` to the docked preview (canvas ≤ 12vh, caption/buttons/status hidden); Enter moves to the next field.
- Phones (≤ 860px) dock the preview card sticky at the top; check 375px width for horizontal overflow after layout changes.

## Hosting

Live at https://driver.thinkweb.me/ (public, no Cloudflare Access by choice).
- nginx: `/etc/nginx/sites-available/driver` serves only `/` → `/var/www/driver/index.html` `/ads.txt`, `/p` (→ `p.html`), and `/vendor/` (wasm/mjs/onnx types, gzip, 7-day cache). `Referrer-Policy` is `strict-origin-when-cross-origin` because AdSense needs the page URL. Security headers are set only at server level; locations use `expires` so they inherit them. A location-level `add_header` would silently drop the CSP.
- Tunnel: `kzp-net` ingress entry in `~/.cloudflared/config.yml`; service `cloudflared.service` (restarting it briefly drops the other routes on the same tunnel). The `warp-routing: enabled` validate warning is pre-existing and harmless.
- Deploy with `/deploy-card` (copies the file and verifies the public copy is byte-identical).
