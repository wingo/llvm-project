; RUN: llc < %s --mtriple=wasm32-unknown-unknown -asm-verbose=false -mattr=+reference-types | FileCheck %s

%func = type void ()
%funcref = type %func addrspace(3)* ;; addrspace 3 is nonintegral

define void @call_funcref(%funcref %ref) {
  call addrspace(3) void %ref() 
  ret void
}

; CHECK-LABEL: call_funcref:
; CHECK-NEXT: functype       call_funcref (funcref) -> ()
; CHECK-NEXT: local.get 0
; CHECK-NEXT: i32.const 0
; CHECK-NEXT: table.set __funcref_call_table
; CHECK-NEXT: local.get 0
; CHECK-NEXT: call_indirect __funcref_call_table, () -> ()
; CHECK-NEXT: end_function

; CHECK: .tabletype __funcref_call_table, funcref
