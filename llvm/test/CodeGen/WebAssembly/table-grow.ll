; RUN: llc --mtriple=wasm32-unknown-unknown -asm-verbose=false -mattr=+reference-types < %s | FileCheck %s

!0 = !{!"externref"}
!wasm.type_info = !{!0}

%wasmref = type ptr addrspace(256)
%externref = type ptr addrspace(257)

@externref_table = local_unnamed_addr addrspace(1) global [0 x %externref] undef

declare i32 @llvm.wasm.table.grow.wasmref(ptr addrspace(1), %wasmref, i32) nounwind readonly
declare %wasmref @llvm.wasm.ref.null(i32) nounwind readonly

define i32 @table_grow(i32 %sz) {
; CHECK-LABEL: table_grow:
; CHECK-NEXT:  .functype	table_grow (i32) -> (i32)
; CHECK-NEXT:  ref.null_extern
; CHECK-NEXT:  local.get	0
; CHECK-NEXT:  table.grow	externref_table
; CHECK-NEXT:  end_function
  %null_untyped = call %wasmref @llvm.wasm.ref.null(i32 0)
  %tableptr = getelementptr [0 x %externref], ptr addrspace(1) @externref_table, i32 0, i32 0
  %newsz = call i32 @llvm.wasm.table.grow.wasmref(ptr addrspace(1) %tableptr, %wasmref %null_untyped, i32 %sz)
  ret i32 %newsz
}
