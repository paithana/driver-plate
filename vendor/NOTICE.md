# Third-party components

Served from `/vendor/` and loaded only when someone uses background removal (“ลบพื้นหลัง”) or licence scanning. All processing runs in the browser.

| Path | Component | Licence |
|---|---|---|
| `ort/` | [onnxruntime-web](https://github.com/microsoft/onnxruntime) 1.30.0 — `ort.wasm.min.js`, `ort-wasm-simd-threaded.{mjs,wasm}` | MIT, © Microsoft Corporation |
| `modnet/model_quantized.onnx` | [MODNet](https://github.com/ZHKKKe/MODNet) portrait matting, ONNX export by [Xenova/modnet](https://huggingface.co/Xenova/modnet) (int8) | Apache-2.0 |
| `tesseract/tesseract.min.js`, `tesseract/worker.min.js` | [Tesseract.js](https://github.com/naptha/tesseract.js) 7.0.0 | Apache-2.0 |
| `tesseract/core/*` | [tesseract.js-core](https://github.com/naptha/tesseract.js-core) 7.0.0 (Tesseract OCR engine compiled to WebAssembly) | Apache-2.0 |
| `tesseract/lang/{tha,eng}.traineddata.gz` | [tessdata_best](https://github.com/tesseract-ocr/tessdata_best) int models via `@tesseract.js-data` 1.0.0 | Apache-2.0 (models); package MIT |
