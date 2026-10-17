#!/usr/bin/env bash
# Fetch the background-removal runtime + model (lazy-loaded by PassengerCard.html, ~21 MB, kept out of git).
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
