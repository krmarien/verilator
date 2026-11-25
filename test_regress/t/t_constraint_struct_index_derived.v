// DESCRIPTION: Verilator: Verilog Test module
//
// This file ONLY is placed under the Creative Commons Public Domain.
// SPDX-FileCopyrightText: 2026 Wilson Snyder
// SPDX-License-Identifier: CC0-1.0

// Inherited constraints on a struct member of a dynamic array element at a constant index

// verilog_format: off
`define stop $stop
`define checkd(gotv,expv) do if ((gotv) !== (expv)) begin $write("%%Error: %s:%0d:  got=%0d exp=%0d\n", `__FILE__,`__LINE__, (gotv), (expv)); `stop; end while(0);
// verilog_format: on

typedef struct {rand int a;} elem_t;

class Base;
  rand elem_t elems[];
  constraint c_base {
    elems.size() == 3;
    elems[1].a == 7;
  }
endclass

class Mid extends Base;
  rand elem_t others[];
  constraint c_mid {
    others.size() == 2;
    others[1].a == elems[1].a + 1;
  }
endclass

class Leaf extends Mid;
endclass

module t;
  initial begin
    automatic Base base = new;
    automatic Mid mid = new;
    automatic Leaf leaf = new;
    automatic int ok;

    ok = base.randomize();
    `checkd(ok, 1);
    `checkd(base.elems[1].a, 7);

    ok = mid.randomize();
    `checkd(ok, 1);
    `checkd(mid.elems.size(), 3);
    `checkd(mid.elems[1].a, 7);
    `checkd(mid.others[1].a, 8);

    ok = leaf.randomize();
    `checkd(ok, 1);
    `checkd(leaf.elems.size(), 3);
    `checkd(leaf.elems[1].a, 7);
    `checkd(leaf.others.size(), 2);
    `checkd(leaf.others[1].a, 8);

    $write("*-* All Finished *-*\n");
    $finish;
  end
endmodule
