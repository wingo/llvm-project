//===-- WebAssemblyUtilities - WebAssembly Utility Functions ---*- C++ -*-====//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
///
/// \file
/// This file contains the declaration of the WebAssembly-specific
/// utility functions.
///
//===----------------------------------------------------------------------===//

#ifndef LLVM_LIB_TARGET_WEBASSEMBLY_WEBASSEMBLYUTILITIES_H
#define LLVM_LIB_TARGET_WEBASSEMBLY_WEBASSEMBLYUTILITIES_H

namespace llvm {

class MachineBasicBlock;
class MachineInstr;
class MachineOperand;
class MCContext;
class MCSymbolWasm;
class StringRef;
class WebAssemblyFunctionInfo;
class WebAssemblySubtarget;

namespace WebAssembly {

// FIXME: Renumber so that EXTERNREF_LOCAL is contiguous with EXTERNREF and
// EXTERNREF_GLOBAL.
// An unscoped enum, as address spaces are often produced and consumed as
// uint32_t or unsigned.
enum WasmAddressSpace {
  // Default address space, for pointers to unmanaged data in linear memory
  // (stack, heap, data).
  WASM_ADDRESS_SPACE_DEFAULT = 0,
  // A non-integral address space used to represent externref values.  We use a
  // separate address space to prevent LLVM from attempting to write them to
  // linear memory.  Because you can't add an offset to one externref value to
  // get a new externref value, we mark this address space as non-integral.
  WASM_ADDRESS_SPACE_EXTERNREF = 1,
  // An integral address space for static-storage-duration locations of
  // externref values.  This address space is integral, to allow for tables to
  // be represented as arrays in IR.
  WASM_ADDRESS_SPACE_EXTERNREF_GLOBAL = 2,
  // A non-integral address space for automatic-storage-duration locations of
  // externref values (local variables).  Non-integral because having the
  // location of one local doesn't give you access to any other local.
  WASM_ADDRESS_SPACE_EXTERNREF_LOCAL = 5,
  // Same as above, but for funcref values.
  WASM_ADDRESS_SPACE_FUNCREF = 3,
  WASM_ADDRESS_SPACE_FUNCREF_GLOBAL = 4,
  WASM_ADDRESS_SPACE_FUNCREF_LOCAL = 6,
};

bool isChild(const MachineInstr &MI, const WebAssemblyFunctionInfo &MFI);
bool mayThrow(const MachineInstr &MI);

// Exception-related function names
extern const char *const ClangCallTerminateFn;
extern const char *const CxaBeginCatchFn;
extern const char *const CxaRethrowFn;
extern const char *const StdTerminateFn;
extern const char *const PersonalityWrapperFn;

/// Returns the operand number of a callee, assuming the argument is a call
/// instruction.
const MachineOperand &getCalleeOp(const MachineInstr &MI);

/// Returns the __indirect_function_table, for use in call_indirect and in
/// function bitcasts.
MCSymbolWasm *
getOrCreateFunctionTableSymbol(MCContext &Ctx,
                               const WebAssemblySubtarget *Subtarget);

/// Returns the __funcref_call_table, for use in funcref calls when lowered to
/// table.set + call_indirect.
MCSymbolWasm *
getOrCreateFuncrefCallTableSymbol(MCContext &Ctx,
                                  const WebAssemblySubtarget *Subtarget);

/// Find a catch instruction from an EH pad. Returns null if no catch
/// instruction found or the catch is in an invalid location.
MachineInstr *findCatch(MachineBasicBlock *EHPad);

} // end namespace WebAssembly

} // end namespace llvm

#endif
