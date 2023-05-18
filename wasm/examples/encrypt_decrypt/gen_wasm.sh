#!/usr/bin/env bash

set -e

# if [ "$#" -ne 1 ]; then
#     echo "Usage: $0 <function-name>"
#     exit 1
# fi

OPENGAUSS_EXPORTED_FUNC=$1
OPENGAUSS_COMPILED_WASM=opengauss-target/wasm32-unknown-unknown/release/opengauss_encrypt_decrypt.wasm
OPENGAUSS_OPTIMIZED_WASM=opengauss-target/opengauss_encrypt_decrypt_optimized.wasm
OPENGAUSS_TARGET_FILE=opengauss-target/create_${OPENGAUSS_EXPORTED_FUNC}.sql

CARGO_TARGET_DIR=opengauss-target cargo build --release --target wasm32-unknown-unknown
wasm-opt -Os $OPENGAUSS_COMPILED_WASM -o $OPENGAUSS_OPTIMIZED_WASM || :
# echo ".init_wasm_func_table -- only needed for shell" > $OPENGAUSS_TARGET_FILE
# echo "DROP FUNCTION IF EXISTS $1;" >> $OPENGAUSS_TARGET_FILE
# echo "CREATE FUNCTION $1 LANGUAGE wasm AS '" >> $OPENGAUSS_TARGET_FILE
# wasm2wat $OPENGAUSS_OPTIMIZED_WASM | sed "s/'/''/g" >> $OPENGAUSS_TARGET_FILE
# echo "';" >> $OPENGAUSS_TARGET_FILE

# if ! grep "export \"$OPENGAUSS_EXPORTED_FUNC\"" $OPENGAUSS_TARGET_FILE; then
#     echo "Error: function $OPENGAUSS_EXPORTED_FUNC not exported from the WebAssembly module"
#     exit 1
# fi
# if ! grep "export \"memory\"" $OPENGAUSS_TARGET_FILE; then
#     echo "Error: memory not exported from the WebAssembly module"
#     exit 1
# fi
