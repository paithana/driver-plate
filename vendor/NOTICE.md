# Third-party components

Served from `/vendor/` and loaded only when someone clicks “ลบพื้นหลัง” (remove background). All processing runs in the browser.

| Path | Component | Licence |
|---|---|---|
| `ort/` | [onnxruntime-web](https://github.com/microsoft/onnxruntime) 1.30.0 — `ort.wasm.min.js`, `ort-wasm-simd-threaded.{mjs,wasm}` | MIT, © Microsoft Corporation |
| `modnet/model_quantized.onnx` | [MODNet](https://github.com/ZHKKKe/MODNet) portrait matting, ONNX export by [Xenova/modnet](https://huggingface.co/Xenova/modnet) (int8) | Apache-2.0 |
