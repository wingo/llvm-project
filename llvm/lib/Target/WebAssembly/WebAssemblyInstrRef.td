// WebAssemblyInstrRef.td - WebAssembly reference type codegen --*- tablegen -*-
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
///
/// \file
/// WebAssembly reference type operand codegen constructs.
///
//===----------------------------------------------------------------------===//

multiclass REF_I<WebAssemblyRegClass reg, ValueType vt> {
  defm REF_NULL_#reg : I<(outs reg:$res), (ins HeapType:$heaptype),
                         (outs), (ins HeapType:$heaptype),
                         [],
                         "ref.null\t$res, $heaptype",
                         "ref.null\t$heaptype",
                         0xd0>,
                       Requires<[HasReferenceTypes]>;
  defm SELECT_#reg: I<(outs reg:$dst), (ins reg:$lhs, reg:$rhs, I32:$cond),
                      (outs), (ins),
                      [(set reg:$dst,
                        (select I32:$cond, reg:$lhs, reg:$rhs))],
                      vt#".select\t$dst, $lhs, $rhs, $cond",
                      vt#".select", 0x1b>,
                    Requires<[HasReferenceTypes]>;

}

defm "" : REF_I<FUNCREF, funcref>;
defm "" : REF_I<EXTERNREF, externref>;

foreach reg = [FUNCREF, EXTERNREF] in {
def : Pat<(select (i32 (setne I32:$cond, 0)), reg:$lhs, reg:$rhs),
          (!cast<Instruction>("SELECT_"#reg) reg:$lhs, reg:$rhs, I32:$cond)>;
def : Pat<(select (i32 (seteq I32:$cond, 0)), reg:$lhs, reg:$rhs),
          (!cast<Instruction>("SELECT_"#reg) reg:$rhs, reg:$lhs, I32:$cond)>;

  // Legalization will lower reference-typed alloca to locals, and lower
  // their uses to WebAssemblyISD::LOCAL_GET /
  // WebAssemblyISD::LOCAL_SET; see WebAssemblyTargetLowering::LowerLoad
  // and WebAssemblyTargetLowering::LowerStore.  These patterns then
  // selct the corresponding machine instructions.
  foreach vt = reg.RegTypes in {
    def : Pat<(vt (WebAssemblylocalGet (i32 timm:$local))),
              (!cast<NI>("LOCAL_GET_" # reg) timm:$local)>,
          Requires<[HasReferenceTypes]>;
    def : Pat<(WebAssemblylocalSet timm:$local, vt:$src),
              (!cast<NI>("LOCAL_SET_" # reg) timm:$local, reg:$src)>,
          Requires<[HasReferenceTypes]>;
  }
}
