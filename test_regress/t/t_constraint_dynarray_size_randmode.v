// DESCRIPTION: Verilator: Verilog Test module
//
// This file ONLY is placed under the Creative Commons Public Domain.
// SPDX-FileCopyrightText: 2026 Wilson Snyder
// SPDX-License-Identifier: CC0-1.0

// A size-constrained dynamic array disabled with rand_mode(0) keeps its size, so an
// incompatible size constraint fails

// verilog_format: off
`define stop $stop
`define checkd(gotv,expv) do if ((gotv) !== (expv)) begin $write("%%Error: %s:%0d:  got=%0d exp=%0d\n", `__FILE__,`__LINE__, (gotv), (expv)); `stop; end while(0);
// verilog_format: on

typedef struct {rand int a;} elem_t;

// Only the size is constrained
class SizeOnly;
  rand int arr[];
  rand int x;
  constraint c {
    arr.size() == 3;
    x == 1;
  }
endclass

// Another array's elements are constrained, so sizes are solved first
class TwoPhase;
  rand int arr[];
  rand elem_t elems[];
  constraint c {
    arr.size() == 3;
    elems.size() == 3;
    elems[1].a == 7;
  }
endclass

class Derived extends SizeOnly;
endclass

module t;
  initial begin
    automatic SizeOnly sizeOnly = new;
    automatic TwoPhase twoPhase = new;
    automatic Derived derived = new;
    automatic int ok;

    sizeOnly.arr.rand_mode(0);
    ok = sizeOnly.randomize();
    `checkd(ok, 0);
    `checkd(sizeOnly.arr.size(), 0);
    ok = sizeOnly.randomize() with {x == 1;};
    `checkd(ok, 0);
    `checkd(sizeOnly.arr.size(), 0);
    sizeOnly.arr.rand_mode(1);
    ok = sizeOnly.randomize();
    `checkd(ok, 1);
    `checkd(sizeOnly.arr.size(), 3);
    // Disabled at a size that satisfies the constraint
    sizeOnly.arr.rand_mode(0);
    ok = sizeOnly.randomize();
    `checkd(ok, 1);
    `checkd(sizeOnly.arr.size(), 3);

    twoPhase.arr.rand_mode(0);
    ok = twoPhase.randomize();
    `checkd(ok, 0);
    `checkd(twoPhase.arr.size(), 0);

    derived.arr.rand_mode(0);
    ok = derived.randomize();
    `checkd(ok, 0);
    `checkd(derived.arr.size(), 0);

    $write("*-* All Finished *-*\n");
    $finish;
  end
endmodule
