//===-- WebAssemblyTypeUtilities.cpp - WebAssembly Type Utility Functions -===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
///
/// \file
/// This file implements several utility functions for WebAssembly type parsing.
///
//===----------------------------------------------------------------------===//

#include "WebAssemblyTypeUtilities.h"
#include "llvm/ADT/StringSwitch.h"
#include "llvm/CodeGen/TargetRegisterInfo.h"
#include "llvm/IR/Module.h"

// Get register classes enum.
#define GET_REGINFO_ENUM
#include "WebAssemblyGenRegisterInfo.inc"

using namespace llvm;

Optional<wasm::ValType> WebAssembly::parseType(StringRef Type) {
  // FIXME: can't use StringSwitch because wasm::ValType doesn't have a
  // "invalid" value.
  if (Type == "i32")
    return wasm::ValType(wasm::ValType::I32);
  if (Type == "i64")
    return wasm::ValType(wasm::ValType::I64);
  if (Type == "f32")
    return wasm::ValType(wasm::ValType::F32);
  if (Type == "f64")
    return wasm::ValType(wasm::ValType::F64);
  if (Type == "v128" || Type == "i8x16" || Type == "i16x8" || Type == "i32x4" ||
      Type == "i64x2" || Type == "f32x4" || Type == "f64x2")
    return wasm::ValType(wasm::ValType::V128);
  if (Type == "funcref")
    return wasm::ValType(wasm::ValType::FUNCREF);
  if (Type == "externref")
    return wasm::ValType(wasm::ValType::EXTERNREF);
  return Optional<wasm::ValType>();
}

WebAssembly::BlockType WebAssembly::parseBlockType(StringRef Type) {
  // Multivalue block types are handled separately in parseSignature
  return StringSwitch<WebAssembly::BlockType>(Type)
      .Case("i32", WebAssembly::BlockType::I32)
      .Case("i64", WebAssembly::BlockType::I64)
      .Case("f32", WebAssembly::BlockType::F32)
      .Case("f64", WebAssembly::BlockType::F64)
      .Case("v128", WebAssembly::BlockType::V128)
      .Case("funcref", WebAssembly::BlockType::Funcref)
      .Case("externref", WebAssembly::BlockType::Externref)
      .Case("void", WebAssembly::BlockType::Void)
      .Default(WebAssembly::BlockType::Invalid);
}

MVT WebAssembly::parseMVT(StringRef Type) {
  return StringSwitch<MVT>(Type)
      .Case("i32", MVT::i32)
      .Case("i64", MVT::i64)
      .Case("f32", MVT::f32)
      .Case("f64", MVT::f64)
      .Case("i64", MVT::i64)
      .Case("v16i8", MVT::v16i8)
      .Case("v8i16", MVT::v8i16)
      .Case("v4i32", MVT::v4i32)
      .Case("v2i64", MVT::v2i64)
      .Default(MVT::INVALID_SIMPLE_VALUE_TYPE);
}

// We have various enums representing a subset of these types, use this
// function to convert any of them to text.
const char *WebAssembly::anyTypeToString(unsigned Type) {
  switch (Type) {
  case wasm::WASM_TYPE_I32:
    return "i32";
  case wasm::WASM_TYPE_I64:
    return "i64";
  case wasm::WASM_TYPE_F32:
    return "f32";
  case wasm::WASM_TYPE_F64:
    return "f64";
  case wasm::WASM_TYPE_V128:
    return "v128";
  case wasm::WASM_TYPE_FUNCREF:
    return "funcref";
  case wasm::WASM_TYPE_EXTERNREF:
    return "externref";
  case wasm::WASM_TYPE_FUNC:
    return "func";
  case wasm::WASM_TYPE_NORESULT:
    return "void";
  default:
    return "invalid_type";
  }
}

const char *WebAssembly::typeToString(wasm::ValType Type) {
  return anyTypeToString(static_cast<unsigned>(Type.Kind));
}

std::string WebAssembly::typeListToString(ArrayRef<wasm::ValType> List) {
  std::string S;
  for (const auto &Type : List) {
    if (&Type != &List[0])
      S += ", ";
    S += WebAssembly::typeToString(Type);
  }
  return S;
}

std::string WebAssembly::signatureToString(const wasm::WasmSignature *Sig) {
  std::string S("(");
  S += typeListToString(Sig->Params);
  S += ") -> (";
  S += typeListToString(Sig->Returns);
  S += ")";
  return S;
}

wasm::ValType WebAssembly::toValType(MVT Type) {
  switch (Type.SimpleTy) {
  case MVT::i32:
    return wasm::ValType::I32;
  case MVT::i64:
    return wasm::ValType::I64;
  case MVT::f32:
    return wasm::ValType::F32;
  case MVT::f64:
    return wasm::ValType::F64;
  case MVT::v16i8:
  case MVT::v8i16:
  case MVT::v4i32:
  case MVT::v2i64:
  case MVT::v4f32:
  case MVT::v2f64:
    return wasm::ValType::V128;
  default:
    llvm_unreachable("unexpected type");
  }
}

wasm::ValType WebAssembly::regClassToValType(unsigned RC) {
  switch (RC) {
  case WebAssembly::I32RegClassID:
    return wasm::ValType::I32;
  case WebAssembly::I64RegClassID:
    return wasm::ValType::I64;
  case WebAssembly::F32RegClassID:
    return wasm::ValType::F32;
  case WebAssembly::F64RegClassID:
    return wasm::ValType::F64;
  case WebAssembly::V128RegClassID:
    return wasm::ValType::V128;
  default:
    llvm_unreachable("unexpected type");
  }
}

wasm::ValType WebAssembly::regClassToValType(const TargetRegisterClass *RC) {
  assert(RC != nullptr);
  return regClassToValType(RC->getID());
}

void WebAssembly::wasmSymbolSetType(const Module &M, MCSymbolWasm *Sym,
                                    const Type *GlobalVT,
                                    const SmallVector<MVT, 1> &VTs) {
  assert(!Sym->getType());

  // Tables are represented as Arrays in LLVM IR therefore
  // they reach this point as aggregate Array types with an element type
  // that is a reference type.
  // FIXME: Will need updating to handle type indexes.
  wasm::ValType ValTy;
  bool IsTable = false;
  if (GlobalVT->isArrayTy() &&
      WebAssembly::isRefType(GlobalVT->getArrayElementType())) {
    IsTable = true;
    const Type *ElTy = GlobalVT->getArrayElementType();
    if (WebAssembly::isExternrefType(ElTy))
      ValTy = wasm::ValType(wasm::ValType::EXTERNREF);
    else if (WebAssembly::isFuncrefType(ElTy))
      ValTy = wasm::ValType(wasm::ValType::FUNCREF);
    else if (WebAssembly::isWasmRefType(ElTy))
      ValTy = retrieveValTypeForWasmRef(M, ElTy->getPointerAddressSpace());
    else
      report_fatal_error("unhandled reference type");
  } else if (VTs.size() == 1) {
    if (VTs[0] == MVT::wasmref)
      ValTy = retrieveValTypeForWasmRef(M, GlobalVT->getPointerAddressSpace());
    else
      ValTy = WebAssembly::toValType(VTs[0]);
  } else
    report_fatal_error("Aggregate globals not yet implemented");

  if (IsTable) {
    Sym->setType(wasm::WASM_SYMBOL_TYPE_TABLE);
    // FIXME: Allow non-nullable table types?
    bool Nullable = true;
    Sym->setTableType(wasm::RefType(wasm::HeapType(ValTy), Nullable));
  } else {
    Sym->setType(wasm::WASM_SYMBOL_TYPE_GLOBAL);
    // FIXME: Allow non-nullable reftyped globals?
    uint8_t ValKind = ValTy.Kind;
    Sym->setGlobalType(wasm::WasmGlobalType{uint8_t(ValKind), /*Mutable=*/true});
  }
}

wasm::ValType WebAssembly::retrieveValTypeForWasmRef(const Module &M, unsigned AS) {
  assert(AS > 255 && "Received a non-wasmref ASID");
  if (AS == 256)
    report_fatal_error("Can't retrieve valtype for untyped wasmref");
  unsigned TypeId = AS - 257;

  NamedMDNode *WasmTypeInfoMD = M.getNamedMetadata("wasm.type_info");
  if (!WasmTypeInfoMD)
    report_fatal_error("Can't retrieve wasm.type_info named metadata");

  unsigned NumTyIds = WasmTypeInfoMD->getNumOperands();
  if (NumTyIds < TypeId)
    report_fatal_error("No metadata for given typeid");

  MDNode *TyInfoMDNode = WasmTypeInfoMD->getOperand(TypeId);
  MDString *TyInfoMDStr = dyn_cast<MDString>(TyInfoMDNode->getOperand(0));
  if (!TyInfoMDStr)
    report_fatal_error("wasm.type_info metadata in unexpected format");

  // TODO: implement "proper" parsing and split out to a separate function.
  // Parsing of more complex types is only performed at this stage for
  // validation purposes. The type won't be used until object emission.
  StringRef TyInfoStr = TyInfoMDStr->getString();
  if (TyInfoStr.consume_front("array ")) {
    Optional<wasm::ValType> Res = parseType(TyInfoStr);
    // TODO: Consider whether to modify TypeID to account for some of the
    // metadata type entries not resulting in entries in the output type
    // table.
    if (Res.has_value())
      return wasm::ValType(wasm::ValType::IDX, TypeId);
    else
      report_fatal_error("Unable to parse array type");
  } else {
    if (TyInfoStr == "externref")
      return wasm::ValType::EXTERNREF;
    if (TyInfoStr == "funcref")
      return wasm::ValType::FUNCREF;
  }

  report_fatal_error("Unable to determine wasm::ValType for given wasmref. "
                     "Can't parse metadata.");
}
