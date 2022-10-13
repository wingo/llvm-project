// WebAssemblyInstrString.td - Wasm StringRef codegen support -*- tablegen -*-//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
///
/// \file
/// WebAssembly StringRef instructions.
///
//===----------------------------------------------------------------------===//

multiclass StringNewOp<string stem, bits<32> opcode> {
  defm NAME : I<(outs WASMREF:$dst), (ins memory_op:$mem, I32:$addr, I32:$len),
          (outs), (ins memory_op:$mem), [],
          "string.new_"#stem#"\t$addr $len",
          "string.new_"#stem, opcode>,
        Requires<[HasStringRef, HasReferenceTypes]>;
  defvar Int = !cast<Intrinsic>("int_wasm_string_new_"#stem);
  defvar Inst = !cast<NI>(NAME);
  def : Pat<(Int I32:$addr, I32:$len), (Inst 0, I32:$addr, I32:$len)>;
}

defm STRING_NEW_UTF8 : StringNewOp<"utf8", 0xfb8b>;
defm STRING_NEW_LOSSY_UTF8 : StringNewOp<"lossy_utf8", 0xfb8c>;
defm STRING_NEW_WTF8 : StringNewOp<"wtf8", 0xfb80>;
defm STRING_NEW_WTF16 : StringNewOp<"wtf16", 0xfb81>;

multiclass StringMeasureOp<string stem, bits<32> opcode> {
  defvar Int = !cast<Intrinsic>("int_wasm_string_measure_"#stem);
  defm NAME : I<(outs I32:$dst), (ins WASMREF:$str), (outs), (ins),
                [(set I32:$dst, (Int WASMREF:$str))],
                "string.measure_"#stem#"\t$str", "string.measure_"#stem,
                opcode>,
              Requires<[HasStringRef, HasReferenceTypes]>;
}

defm STRING_MEASURE_UTF8 : StringMeasureOp<"utf8", 0xfb83>;
defm STRING_MEASURE_WTF8 : StringMeasureOp<"wtf8", 0xfb84>;
defm STRING_MEASURE_WTF16 : StringMeasureOp<"wtf16", 0xfb85>;

multiclass StringEncodeOp<string stem, bits<32> opcode> {
  defm NAME : I<(outs I32:$dst), (ins memory_op:$mem, WASMREF:$str, I32:$addr),
          (outs), (ins memory_op:$mem), [],
          "string.encode_"#stem#"\t$str $addr",
          "string.encode_"#stem, opcode>,
        Requires<[HasStringRef, HasReferenceTypes]>;
  defvar Int = !cast<Intrinsic>("int_wasm_string_encode_"#stem);
  defvar Inst = !cast<NI>(NAME);
  def : Pat<(Int WASMREF:$str, I32:$addr), (Inst 0, WASMREF:$str, I32:$addr)>;
}

defm STRING_ENCODE_UTF8 : StringEncodeOp<"utf8", 0xfb86>;
defm STRING_ENCODE_LOSSY_UTF8 : StringEncodeOp<"lossy_utf8", 0xfb8d>;
defm STRING_ENCODE_WTF8 : StringEncodeOp<"wtf8", 0xfb8e>;
defm STRING_ENCODE_WTF16 : StringEncodeOp<"wtf16", 0xfb87>;

defm STRING_CONCAT : I<(outs WASMREF:$dst), (ins WASMREF:$a, WASMREF:$b),
                       (outs), (ins),
                        [(set WASMREF:$dst,
                              (int_wasm_string_concat WASMREF:$a, WASMREF:$b))],
                       "string.concat\t$a $b", "string.concat", 0xfb88>,
                     Requires<[HasStringRef, HasReferenceTypes]>;
defm STRING_EQ : I<(outs I32:$dst), (ins WASMREF:$a, WASMREF:$b),
                   (outs), (ins),
                   [(set I32:$dst,
                         (int_wasm_string_eq WASMREF:$a, WASMREF:$b))],
                   "string.eq\t$a $b", "string.eq", 0xfb89>,
                 Requires<[HasStringRef, HasReferenceTypes]>;
defm STRING_IS_USV_SEQUENCE :
   I<(outs I32:$dst), (ins WASMREF:$str), (outs), (ins),
     [(set I32:$dst, (int_wasm_string_is_usv_sequence WASMREF:$str))],
     "string.is_usv_sequence\t$str", "string.is_usv_sequence", 0xfb8a>,
   Requires<[HasStringRef, HasReferenceTypes]>;
