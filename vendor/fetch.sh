#!/usr/bin/env bash
# Fetch the lazy-loaded runtimes + models for background removal and licence OCR (kept out of git).
# Pinned versions, verified by sha256. Usage: vendor/fetch.sh
set -euo pipefail
cd "$(dirname "$0")"
ORT=1.30.0
fetch() { # url dest sha256
  if [[ -f "$2" ]] && echo "$3  $2" | sha256sum -c --status; then return; fi
  mkdir -p "$(dirname "$2")"; curl -fsSL -o "$2.part" "$1"
  echo "$3  $2.part" | sha256sum -c --status || { echo "checksum mismatch: $2" >&2; rm -f "$2.part"; exit 1; }
  mv "$2.part" "$2"; echo "fetched $2"
}
fetch "https://cdn.jsdelivr.net/npm/onnxruntime-web@$ORT/dist/ort.wasm.min.js" ort/ort.wasm.min.js faece07e84faa9001f5104bbe4e5c70861d06cb2376a0dea1fa0ad33a67adc81
fetch "https://cdn.jsdelivr.net/npm/onnxruntime-web@$ORT/dist/ort-wasm-simd-threaded.mjs" ort/ort-wasm-simd-threaded.mjs e13f7f94fc51b4ca72b12faeb1ee95f4ace6dfbc8939bc718aabdc0a27c4299b
fetch "https://cdn.jsdelivr.net/npm/onnxruntime-web@$ORT/dist/ort-wasm-simd-threaded.wasm" ort/ort-wasm-simd-threaded.wasm 3398c10d07d229bd91b364548e130e0e51a8e5704b88c7c083ebbeb78842dee2
fetch "https://huggingface.co/Xenova/modnet/resolve/main/onnx/model_quantized.onnx" modnet/model_quantized.onnx 92e49898c3e05a6d7a944fc67a8cb87c4aad754ffb6ebd949528c7d1105fee3a

TJS=7.0.0
fetch "https://cdn.jsdelivr.net/npm/tesseract.js@$TJS/dist/tesseract.min.js" tesseract/tesseract.min.js 000c27d9cd0def655f77b36c72a389c0ab13793aa31cb4d7aab56d09c0afbc7e
fetch "https://cdn.jsdelivr.net/npm/tesseract.js@$TJS/dist/worker.min.js" tesseract/worker.min.js 576b7df7e3393e137e51849357c9adb53fe7ac1bb69bfa06cf3d61520f182c6d
fetch "https://cdn.jsdelivr.net/npm/tesseract.js-core@$TJS/tesseract-core-lstm.wasm.js" tesseract/core/tesseract-core-lstm.wasm.js eef5f8b2f8e20e150680b20adaec4a60babafee3adbe8a94583c81fee46e8680
fetch "https://cdn.jsdelivr.net/npm/tesseract.js-core@$TJS/tesseract-core-simd-lstm.wasm.js" tesseract/core/tesseract-core-simd-lstm.wasm.js c58b46a4c796c0b8afccf77591d5b875b6896b45d402bbce8caa6f5362447b38
fetch "https://cdn.jsdelivr.net/npm/tesseract.js-core@$TJS/tesseract-core-relaxedsimd-lstm.wasm.js" tesseract/core/tesseract-core-relaxedsimd-lstm.wasm.js 861a536cf9ef8e63cb644d57bab39c388f37f7d6b6f60024b741c5f6b39a59b3
fetch "https://cdn.jsdelivr.net/npm/@tesseract.js-data/tha@1.0.0/4.0.0_best_int/tha.traineddata.gz" tesseract/lang/tha.traineddata.gz 4550a5505184d1b79cf10416d5b19e643001d95411d5e717954dd26feef3ae74
fetch "https://cdn.jsdelivr.net/npm/@tesseract.js-data/eng@1.0.0/4.0.0_best_int/eng.traineddata.gz" tesseract/lang/eng.traineddata.gz 45b4cb346724ac1774f1c36f42f182b887bcdb28ebe63e6fff90ac41f3fcff91
