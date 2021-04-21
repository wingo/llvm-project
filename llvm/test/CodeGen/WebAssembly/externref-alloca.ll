; RUN: llc < %s -mtriple=wasm32-unknown-unknown -asm-verbose=false -mattr=+reference-types | FileCheck %s

;; Address space 1 is for externref values, and address space 5 is for
;; externref-valued local variables.

%extern = type opaque
%externref = type %extern addrspace(1)*
%externref_local = type %externref addrspace(5)*

; CHECK-LABEL: alloca_externref:
define %externref @alloca_externref(%externref %param) {
 ; CHECK-NEXT: .functype alloca_externref (externref) -> (externref)
 %retval = alloca %externref, addrspace(5)
 ; CHECK-NEXT: .local externref
 ; CHECK-NEXT: local.get 0
 ; CHECK-NEXT: local.set 1
 store %externref %param, %externref_local %retval
 ; CHECK-NEXT: local.get 1
 %reloaded = load %externref, %externref_local %retval
 ; CHECK-NEXT: end_function
 ret %externref %reloaded
}
