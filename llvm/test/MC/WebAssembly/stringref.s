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

string_measure_utf8:
  .functype string_measure_utf8 (stringref) -> (i32)
  local.get 0
  string.measure_utf8
  end_function
# CHECK: <string_measure_utf8>:
# CHECK:             20 00	local.get	0
# CHECK-NEXT:        fb 83 01  	string.measure_utf8
# CHECK-NEXT:        0b           	end

string_measure_wtf8:
  .functype string_measure_wtf8 (stringref) -> (i32)
  local.get 0
  string.measure_wtf8
  end_function
# CHECK: <string_measure_wtf8>:
# CHECK:             20 00	local.get	0
# CHECK-NEXT:        fb 84 01  	string.measure_wtf8
# CHECK-NEXT:        0b           	end

string_measure_wtf16:
  .functype string_measure_wtf16 (stringref) -> (i32)
  local.get 0
  string.measure_wtf16
  end_function
# CHECK: <string_measure_wtf16>:
# CHECK:             20 00	local.get	0
# CHECK-NEXT:        fb 85 01  	string.measure_wtf16
# CHECK-NEXT:        0b           	end

string_encode_utf8:
  .functype string_encode_utf8 (stringref, i32) -> (i32)
  local.get 0
  local.get 1
  string.encode_utf8
  end_function
# CHECK: <string_encode_utf8>:
# CHECK:             20 00	local.get	0
# CHECK:             20 01	local.get	1
# CHECK-NEXT:        fb 86 01 00  	string.encode_utf8
# CHECK-NEXT:        0b         end

string_encode_lossy_utf8:
  .functype string_encode_lossy_utf8 (stringref, i32) -> (i32)
  local.get 0
  local.get 1
  string.encode_lossy_utf8
  end_function
# CHECK: <string_encode_lossy_utf8>:
# CHECK:             20 00	local.get	0
# CHECK:             20 01	local.get	1
# CHECK-NEXT:        fb 8d 01 00  	string.encode_lossy_utf8
# CHECK-NEXT:        0b         end

string_encode_wtf8:
  .functype string_encode_wtf8 (stringref, i32) -> (i32)
  local.get 0
  local.get 1
  string.encode_wtf8
  end_function
# CHECK: <string_encode_wtf8>:
# CHECK:             20 00	local.get	0
# CHECK:             20 01	local.get	1
# CHECK-NEXT:        fb 8e 01 00  	string.encode_wtf8
# CHECK-NEXT:        0b         end

string_encode_wtf16:
  .functype string_encode_wtf16 (stringref, i32) -> (i32)
  local.get 0
  local.get 1
  string.encode_wtf16
  end_function
# CHECK: <string_encode_wtf16>:
# CHECK:             20 00	local.get	0
# CHECK:             20 01	local.get	1
# CHECK-NEXT:        fb 87 01 00  	string.encode_wtf16
# CHECK-NEXT:        0b         end

string_concat:
  .functype string_concat (stringref, stringref) -> (stringref)
  local.get 0
  local.get 1
  string.concat
  end_function
# CHECK: <string_concat>:
# CHECK:             20 00	local.get	0
# CHECK:             20 01	local.get	1
# CHECK-NEXT:        fb 88 01  	string.concat
# CHECK-NEXT:        0b         end

string_eq:
  .functype string_eq (stringref, stringref) -> (i32)
  local.get 0
  local.get 1
  string.eq
  end_function
# CHECK: <string_eq>:
# CHECK:             20 00	local.get	0
# CHECK:             20 01	local.get	1
# CHECK-NEXT:        fb 89 01  	string.eq
# CHECK-NEXT:        0b         end

string_is_usv_sequence:
  .functype string_is_usv_sequence (stringref) -> (i32)
  local.get 0
  string.is_usv_sequence
  end_function
# CHECK: <string_is_usv_sequence>:
# CHECK:             20 00	local.get	0
# CHECK-NEXT:        fb 8a 01  	string.is_usv_sequence
# CHECK-NEXT:        0b         end
