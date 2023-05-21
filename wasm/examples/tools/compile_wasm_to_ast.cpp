#include <wasmedge/wasmedge.h>
#include <stdio.h>
int main(int Argc, const char* Argv[]) {
  /* Create the configure context. */
  WasmEdge_ConfigureContext *ConfCxt = WasmEdge_ConfigureCreate();
  /* ... Adjust settings in the configure context. */
  /* Result. */
  WasmEdge_Result Res;

  /* Create the compiler context. The configure context can be NULL. */
  WasmEdge_CompilerContext *CompilerCxt = WasmEdge_CompilerCreate(ConfCxt);
  /* Compile the WASM file with input and output paths. */
  Res = WasmEdge_CompilerCompile(CompilerCxt, Argv[1], Argv[2]);
  if (!WasmEdge_ResultOK(Res)) {
    printf("Compilation failed: %s\n", WasmEdge_ResultGetMessage(Res));
    return 1;
  }

  WasmEdge_CompilerDelete(CompilerCxt);
  WasmEdge_ConfigureDelete(ConfCxt);
  return 0;
}
