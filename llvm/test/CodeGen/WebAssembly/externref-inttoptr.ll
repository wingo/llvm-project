; RUN: not --crash llc < %s --mtriple=wasm32-unknown-unknown -asm-verbose=false -mattr=+reference-types 2>&1 | FileCheck %s

!0 = !{!"externref"}
!wasm.type_info = !{!0}

%externref = type ptr addrspace(257)

define %externref @int_to_externref(i32 %i) {
  %ref = inttoptr i32 %i to %externref
  ret %externref %ref
}

; CHECK: LLVM ERROR: Can't create local.get for an undef wasmref
