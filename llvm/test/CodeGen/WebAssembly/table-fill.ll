; RUN: llc --mtriple=wasm32-unknown-unknown -asm-verbose=false -mattr=+reference-types < %s | FileCheck %s

!0 = !{!"externref"}
!wasm.type_info = !{!0}

%wasmref = type ptr addrspace(256)
%externref = type ptr addrspace(257)

@externref_table = local_unnamed_addr addrspace(1) global [0 x %externref] undef

declare void @llvm.wasm.table.fill.wasmref(ptr addrspace(1), i32, %wasmref, i32) nounwind readonly

define void @table_fill(i32 %start, i32 %len, %externref %val) {
; CHECK-LABEL: table_fill:
; CHECK-NEXT:  .functype	table_fill (i32, i32, externref) -> ()
; CHECK-NEXT:  local.get    0
; CHECK-NEXT:  local.get    2
; CHECK-NEXT:  local.get    1
; CHECK-NEXT:  table.fill	externref_table
; CHECK-NEXT:  end_function
  %tableptr = getelementptr [0 x %externref], ptr addrspace(1) @externref_table, i32 0, i32 0
  %val_untyped = addrspacecast %externref %val to %wasmref
  call void @llvm.wasm.table.fill.wasmref(ptr addrspace(1) %tableptr, i32 %start, %wasmref %val_untyped, i32 %len)
  ret void
}
