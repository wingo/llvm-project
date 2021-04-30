; RUN: llc < %s --mtriple=wasm32-unknown-unknown -asm-verbose=false -mattr=+reference-types | FileCheck %s

%extern = type opaque
%externref = type %extern addrspace(10)* ;; addrspace 1 is nonintegral

@externref_global = local_unnamed_addr addrspace(1) global %externref undef

define %extern @return_extern_undef() {
  ret %extern undef
}

; CHECK-LABEL: return_extern_undef:
; CHECK-NEXT: functype       return_extern_undef () -> ()
; CHECK-NEXT: end_function

; CHECK: .globl externref_global

