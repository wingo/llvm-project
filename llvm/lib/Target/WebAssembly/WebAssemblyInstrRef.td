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
                              !eq(lowert, "extern") : 0xd06f,
                              !eq(lowert, "string") : 0xd064,
                              !eq(lowert, "stringview_wtf8") : 0xd063,
                              !eq(lowert, "stringview_wtf16") : 0xd062,
                              !eq(lowert, "stringview_iter") : 0xd061)>,
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
defm "" : REF_I<"STRINGREF", "string">;
defm "" : REF_I<"STRINGVIEW_WTF8", "stringview_wtf8">;
defm "" : REF_I<"STRINGVIEW_WTF16", "stringview_wtf16">;
defm "" : REF_I<"STRINGVIEW_ITER", "stringview_iter">;

defm REF_IS_NULL_WASMREF
    : I<(outs I32:$dst), (ins WASMREF:$ref), (outs), (ins),
        [(set I32:$dst, (int_wasm_ref_is_null WASMREF:$ref))],
        "ref.is_null\t$ref",
        "ref.is_null", 0xd1>,
      Requires<[HasReferenceTypes]>;
