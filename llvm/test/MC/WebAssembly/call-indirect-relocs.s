# RUN: llvm-mc -triple=wasm32-unknown-unknown -mattr=+reference-types < %s | FileCheck %s
# not yet: llvm-mc -triple=wasm32-unknown-unknown -filetype=obj -mattr=+reference-types -o %t.o < %s | obj2yaml | FileCheck -check-prefix=CHECK-OBJ %s

test0:
    .functype   test0 () -> ()
    i32.const 42
    f64.const 2.5
    i32.const   0
    call_indirect (i32, f64) -> (), __indirect_function_table
    end_function

.tabletype empty_fref_table, funcref
empty_fref_table:


# CHECK:           .text
# CHECK-LABEL: test0:
# CHECK-NEXT:      .functype   test0 () -> ()
# CHECK-NEXT:      i32.const   42
# CHECK-NEXT:      f64.const   0x1.4p1
# CHECK-NEXT:      i32.const   0
# CHECK-NEXT:      call_indirect (i32, f64) -> (), __indirect_function_table
# CHECK-NEXT:      end_function

# CHECK:           .tabletype empty_fref_table, funcref
# CHECK: empty_fref_table:
