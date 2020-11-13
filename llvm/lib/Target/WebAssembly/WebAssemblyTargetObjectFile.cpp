//===-- WebAssemblyTargetObjectFile.cpp - WebAssembly Object Info ---------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
///
/// \file
/// This file defines the functions of the WebAssembly-specific subclass
/// of TargetLoweringObjectFile.
///
//===----------------------------------------------------------------------===//

#include "WebAssemblyTargetObjectFile.h"
#include "WebAssemblyTargetMachine.h"
#include "llvm/IR/Mangler.h"
#include "llvm/MC/MCContext.h"
#include "llvm/MC/MCSymbolWasm.h"

using namespace llvm;

void WebAssemblyTargetObjectFile::Initialize(MCContext &Ctx,
                                             const TargetMachine &TM) {
  TargetLoweringObjectFileWasm::Initialize(Ctx, TM);
  InitializeWasm();
}

// This function is called within TargetMachine::getSymbol to give the target a
// first crack at looking up a symbol for a value, before falling back to
// getOrCreateSymbol.  We override it in order to propagate information from the
// GlobalValue to the symbol, e.g. is it a function or not.
MCSymbol *
WebAssemblyTargetObjectFile::getTargetSymbol(const GlobalValue *GV,
                                             const TargetMachine &TM) const {
  SmallString<128> NameStr;
  TM.getNameWithPrefix(NameStr, GV, getMangler());
  if (auto *Sym = getContext().lookupSymbol(NameStr)) {
    // FIXME: Could check expected symbol type here.
    return Sym;
  }

  // Symbol will be created with type WASM_SYMBOL_TYPE_DATA by default.
  auto WasmSym = cast<MCSymbolWasm>(getContext().getOrCreateSymbol(NameStr));

  if (isa<Function>(GV))
    WasmSym->setType(wasm::WASM_SYMBOL_TYPE_FUNCTION);
  // FIXME: When we add codegen support for user-defined values of type
  // WASM_SYMBOL_TYPE_GLOBAL, WASM_SYMBOL_TYPE_TABLE, and
  // wasm::WASM_SYMBOL_TYPE_EVENT, add more cases here.

  return WasmSym;
}
