#!/usr/bin/env bash

set -e

OPENGAUSS_EXPORTED_FUNC=$1
OPENGAUSS_COMPILED_WASM=opengauss-target/wasm32-unknown-unknown/release/opengauss_encrypt_decrypt.wasm
OPENGAUSS_OPTIMIZED_WASM=opengauss-target/encrypt_decrypt.wasm

CARGO_TARGET_DIR=opengauss-target cargo build --release --target wasm32-unknown-unknown
wasm-opt -Os $OPENGAUSS_COMPILED_WASM -o $OPENGAUSS_OPTIMIZED_WASM || :

