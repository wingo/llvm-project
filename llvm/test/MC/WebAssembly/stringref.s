# RUN: llvm-mc -triple=wasm32-unknown-unknown -filetype=obj -o %t.o -mattr=+reference-types,+stringref < %s
# RUN: llvm-objdump --triple=wasm32-unknown-unknown -d %t.o | FileCheck %s

string_new_utf8:
  .functype string_new_utf8 (i32, i32) -> (stringref)
  local.get 0
  local.get 1
  string.new_utf8
  end_function
# CHECK: <string_new_utf8>:
# CHECK:             20 00      local.get 0
# CHECK-NEXT:        20 01      local.get 1
# CHECK-NEXT:        fb 8b 01 00  	string.new_utf8
# CHECK-NEXT:        0b           	end

string_new_lossy_utf8:
  .functype string_new_lossy_utf8 (i32, i32) -> (stringref)
  local.get 0
  local.get 1
  string.new_lossy_utf8
  end_function
# CHECK: <string_new_lossy_utf8>:
# CHECK:             20 00      local.get 0
# CHECK-NEXT:        20 01      local.get 1
# CHECK-NEXT:        fb 8c 01 00  	string.new_lossy_utf8
# CHECK-NEXT:        0b           	end

string_new_wtf8:
  .functype string_new_wtf8 (i32, i32) -> (stringref)
  local.get 0
  local.get 1
  string.new_wtf8
  end_function
# CHECK: <string_new_wtf8>:
# CHECK:             20 00      local.get 0
# CHECK-NEXT:        20 01      local.get 1
# CHECK-NEXT:        fb 80 01 00  	string.new_wtf8
# CHECK-NEXT:        0b           	end

string_new_wtf16:
  .functype string_new_wtf16 (i32, i32) -> (stringref)
  local.get 0
  local.get 1
  string.new_wtf16
  end_function
# CHECK: <string_new_wtf16>:
# CHECK:             20 00      local.get 0
# CHECK-NEXT:        20 01      local.get 1
# CHECK-NEXT:        fb 81 01 00  	string.new_wtf16
# CHECK-NEXT:        0b           	end
