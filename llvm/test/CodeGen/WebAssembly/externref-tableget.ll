; RUN: llc < %s --mtriple=wasm32-unknown-unknown -asm-verbose=false -mattr=+reference-types | FileCheck %s

!0 = !{!"externref"}
!wasm.type_info = !{!0}

%externref = type ptr addrspace(257)

@externref_table = local_unnamed_addr addrspace(1) global [0 x %externref] undef

define %externref @get_externref_from_table(i32 %i) {
; CHECK-LABEL: get_externref_from_table:
; CHECK-NEXT: .functype       get_externref_from_table (i32) -> (externref)
; CHECK-NEXT: local.get 0
; CHECK-NEXT: table.get externref_table
; CHECK-NEXT: end_function
  %p = getelementptr [0 x %externref], ptr addrspace(1) @externref_table, i32 0, i32 %i
  %ref = load %externref, ptr addrspace(1) %p
  ret %externref %ref
}

define %externref @get_externref_from_table_const() {
; CHECK-LABEL: get_externref_from_table_const:
; CHECK-NEXT:  .functype      get_externref_from_table_const () -> (externref)
; CHECK-NEXT:  i32.const      0
; CHECK-NEXT:  table.get      externref_table
; CHECK-NEXT:  end_function
  %p = getelementptr [0 x %externref], ptr addrspace (1) @externref_table, i32 0, i32 0
  %ref = load %externref, ptr addrspace(1) %p
  ret %externref %ref
}

define %externref @get_externref_from_table_with_offset(i32 %i) {
; CHECK-LABEL: get_externref_from_table_with_offset:
; CHECK-NEXT:  .functype       get_externref_from_table_with_offset (i32) -> (externref)
; CHECK-NEXT:  local.get       0
; CHECK-NEXT:  i32.const       2
; CHECK-NEXT:  i32.add
; CHECK-NEXT:  table.get       externref_table
; CHECK-NEXT:  end_function
  %off = add nsw i32 %i, 2
  %p = getelementptr [0 x %externref], ptr addrspace (1) @externref_table, i32 0, i32 %off
  %ref = load %externref, ptr addrspace(1) %p
  ret %externref %ref
}


define %externref @get_externref_from_table_with_var_offset(i32 %i, i32 %j) {
; CHECK-LABEL: get_externref_from_table_with_var_offset:
; CHECK-NEXT:  .functype       get_externref_from_table_with_var_offset (i32, i32) -> (externref)
; CHECK-NEXT:  local.get       0
; CHECK-NEXT:  local.get       1
; CHECK-NEXT:  i32.add
; CHECK-NEXT:  table.get       externref_table
; CHECK-NEXT:  end_function
  %off = add nsw i32 %i, %j
  %p = getelementptr [0 x %externref], ptr addrspace (1) @externref_table, i32 0, i32 %off
  %ref = load %externref, ptr addrspace(1) %p
  ret %externref %ref
}

declare i32 @get_offset()

define %externref @get_externref_from_table_with_var_offset2(i32 %i) {
; CHECK-LABEL: get_externref_from_table_with_var_offset2:
; CHECK-NEXT:  .functype       get_externref_from_table_with_var_offset2 (i32) -> (externref)
; CHECK-NEXT:  local.get       0
; CHECK-NEXT:  call    get_offset
; CHECK-NEXT:  i32.add
; CHECK-NEXT:  table.get       externref_table
; CHECK-NEXT:  end_function
  %j = call i32 @get_offset()
  %off = add nsw i32 %i, %j
  %p = getelementptr [0 x %externref], ptr addrspace (1) @externref_table, i32 0, i32 %off
  %ref = load %externref, ptr addrspace(1) %p
  ret %externref %ref
}

; CHECK:       .tabletype externref_table, externref
; CHECK-LABEL: externref_table:
