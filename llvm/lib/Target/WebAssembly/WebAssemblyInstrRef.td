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

multiclass REF_I<string capt, string lowert> {
  defm REF_NULL_WASMREF_#capt : I<(outs WASMREF:$dst), (ins),
                        (outs), (ins),
                        [],
                        "ref.null_" # lowert # "$dst",
                        "ref.null_" # lowert,
                        !cond(!eq(lowert, "func")   : 0xd070,
                              !eq(lowert, "extern") : 0xd06f)>,
                      Requires<[HasReferenceTypes]>;
  defm SELECT_WASMREF_#capt: I<(outs WASMREF:$dst), (ins WASMREF:$lhs, WASMREF:$rhs, I32:$cond),
                     (outs), (ins),
                     [],
                     lowert#"ref.select\t$dst, $lhs, $rhs, $cond",
                     lowert#"ref.select", 0x1b>,
                   Requires<[HasReferenceTypes]>;
}

defm "" : REF_I<"FUNCREF", "func">;
defm "" : REF_I<"EXTERNREF", "extern">;

defm REF_IS_NULL_WASMREF
    : I<(outs I32:$dst), (ins WASMREF:$ref), (outs), (ins),
        [(set I32:$dst, (int_wasm_ref_is_null WASMREF:$ref))],
        "ref.is_null\t$ref",
        "ref.is_null", 0xd1>,
      Requires<[HasReferenceTypes]>;
