; RUN: not llc --mtriple=wasm32-unknown-unknown -asm-verbose=false -mattr=+reference-types < %s 2>&1 | FileCheck %s --check-prefix=CHECK-ERROR

!0 = !{!"externref"}
!wasm.type_info = !{!0}

%externref = type ptr addrspace(257)

define void @load_extern(%externref %ref) {
  %e = load %extern, %externref %ref
  ret void
}

; CHECK-ERROR: error: loading unsized types is not allowed
