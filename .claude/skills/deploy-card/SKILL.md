---
name: deploy-card
description: Deploy DriverCard.html to https://driver.thinkweb.me/ — syntax-check, install to /var/www/driver, and verify the public copy matches byte-for-byte.
disable-model-invocation: true
---

Deploy the DriverCard page. Stop and report at the first failing step.

1. Pre-flight checks in `/home/kzp/driver-plate`:
   - App script parses: extract the last `<script data-cfasync="false">` block to a temp file and run `node --check` on it.
   - Every `<script` tag carries `data-cfasync="false"` (count of `\n<script>\n` must be 0).
   - Defaults are still the fake sample: `nameTh: 'นาย สมชาย ใจดี'`, `licenseNo: 'ภก.0000/00'`, `regNo: '00-0000'` and `var SAMPLE_PHOTO = '';` must each appear exactly once. Compare against `DriverCard.orig.html` if unsure, but never copy its values into the repo or into this skill.
2. Install:
   - `vendor/fetch.sh` (a no-op when the files are already present and checksums match)
   - `sudo install -d -m 755 /var/www/driver/vendor/ort /var/www/driver/vendor/modnet /var/www/driver/vendor/tesseract/core /var/www/driver/vendor/tesseract/lang`
   - `sudo install -m 644 vendor/ort/* /var/www/driver/vendor/ort/ && sudo install -m 644 vendor/modnet/* /var/www/driver/vendor/modnet/ && sudo install -m 644 vendor/NOTICE.md /var/www/driver/vendor/`
   - `sudo install -m 644 vendor/tesseract/*.js /var/www/driver/vendor/tesseract/ && sudo install -m 644 vendor/tesseract/core/* /var/www/driver/vendor/tesseract/core/ && sudo install -m 644 vendor/tesseract/lang/* /var/www/driver/vendor/tesseract/lang/`
   - `sudo install -m 644 ads.txt /var/www/driver/ads.txt`
   - `sudo install -m 644 p.html /var/www/driver/p.html`
   - `sudo install -m 644 DriverCard.html /var/www/driver/index.html`
3. Verify: `curl -s --compressed https://driver.thinkweb.me/ -o <scratch>/pub.html` and `cmp` it against the local file. Do the same for `https://driver.thinkweb.me/p` against `p.html`. If it differs, show the first differing bytes — a `type="…-text/javascript"` rewrite means Rocket Loader caught a script without `data-cfasync="false"`.
   Also `curl -s -o /dev/null -w '%{http_code} %{content_type}'` each `/vendor/ort/*` and `/vendor/modnet/model_quantized.onnx` URL: expect 200 with `application/javascript`, `application/wasm` or `application/octet-stream`.
4. If the change touched licence OCR, upload a *fictional* licence image via "อัปโหลดรูป" and confirm the review panel lists the fields. If it touched background removal, upload a head-and-shoulders photo, click "ลบพื้นหลัง", and confirm the colour swatches appear with no console errors.
5. If the change touched layout or styles, open the page in the browser at 1280px and 375px, confirm no console errors and `scrollWidth === innerWidth` on the phone width.
6. Report: deployed size, cmp result, and anything checked in steps 4–5.

$ARGUMENTS
