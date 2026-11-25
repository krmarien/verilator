// DESCRIPTION: Verilator: Verilog Test module
//
// This file ONLY is placed under the Creative Commons Public Domain.
// SPDX-FileCopyrightText: 2026 Wilson Snyder
// SPDX-License-Identifier: CC0-1.0

// Size constraints on dynamic arrays and queues of a rand class member, solved
// by the randomize() of the class holding the member

// verilog_format: off
`define stop $stop
`define checkd(gotv,expv) do if ((gotv) !== (expv)) begin $write("%%Error: %s:%0d:  got=%0d exp=%0d\n", `__FILE__,`__LINE__, (gotv), (expv)); `stop; end while(0);
// verilog_format: on

typedef struct {rand int a;} elem_t;

typedef class Holder;
typedef class Free;

// Declared before the member's class, so lowered first
class Outer;
  rand Holder h1;
  rand Holder h2;
  rand int x;
  constraint c_x {
    x == 1;
    h1.arr[0] == h2.arr[1] + 1;
  }
  function new();
    h1 = new;
    h2 = new;
  endfunction
endclass

class Holder;
  rand int arr[];
  rand int q[$];
  rand elem_t elems[];
  rand int n;
  constraint c_size {
    n inside {[2 : 4]};
    arr.size() == n;
    q.size() == 2;
    elems.size() == 3;
    foreach (arr[i]) arr[i] inside {[1 : 9]};
  }
endclass

class Mid;
  rand Holder h;
  function new();
    h = new;
  endfunction
endclass

// A struct array element at a constant index
class Elems;
  rand Holder h;
  constraint c_e {h.elems[1].a == 7;}
  function new();
    h = new;
  endfunction
endclass

// Two levels down
class Top;
  rand Mid m;
  constraint c_m {m.h.arr[1] == 5;}
  function new();
    m = new;
  endfunction
endclass

// Conflicts with the member class's size constraint
class Conflict;
  rand Holder h;
  constraint c_q {h.q.size() == 5;}
  function new();
    h = new;
  endfunction
endclass

// Size constrained only by the class holding the member
class Sized;
  rand Free f;
  constraint c_f {
    f.arr.size() == 4;
    f.arr.size() > 1;
    foreach (f.arr[i]) f.arr[i] == i;
    f.aa.size() == 2;
  }
  function new();
    f = new;
  endfunction
endclass

class Free;
  rand int arr[];
  rand int aa[int];  // Not resized (IEEE 1800-2023 18.4)
endclass

class Derived extends Outer;
  constraint c_n {h1.n == 4;}
endclass

module t;
  initial begin
    automatic Outer outer = new;
    automatic Elems elems = new;
    automatic Top top = new;
    automatic Conflict conflict = new;
    automatic Sized sized = new;
    automatic Derived derived = new;
    automatic Holder holder = new;
    automatic int ok;

    repeat (10) begin
      ok = outer.randomize();
      `checkd(ok, 1);
      foreach (outer.h1.arr[i]) `checkd(outer.h1.arr[i] inside {[1 : 9]}, 1'b1);
      `checkd(outer.h1.arr.size(), outer.h1.n);
      `checkd(outer.h2.arr.size(), outer.h2.n);
      `checkd(outer.h1.q.size(), 2);
      `checkd(outer.h1.elems.size(), 3);
      `checkd(outer.h1.arr[0], outer.h2.arr[1] + 1);
    end

    ok = elems.randomize();
    `checkd(ok, 1);
    `checkd(elems.h.elems.size(), 3);
    `checkd(elems.h.elems[1].a, 7);

    ok = top.randomize();
    `checkd(ok, 1);
    `checkd(top.m.h.arr.size(), top.m.h.n);
    `checkd(top.m.h.arr[1], 5);

    ok = conflict.randomize();
    `checkd(ok, 0);

    sized.f.aa[5] = 1;
    sized.f.aa[9] = 2;
    ok = sized.randomize();
    `checkd(ok, 1);
    `checkd(sized.f.arr.size(), 4);
    `checkd(sized.f.aa.size(), 2);
    foreach (sized.f.arr[i]) `checkd(sized.f.arr[i], i);

    ok = derived.randomize();
    `checkd(ok, 1);
    `checkd(derived.h1.arr.size(), 4);

    // A frozen array keeps its size
    outer = new;
    outer.h1.arr.rand_mode(0);
    ok = outer.randomize();
    `checkd(ok, 0);
    `checkd(outer.h1.arr.size(), 0);
    outer.h1.arr.rand_mode(1);
    ok = outer.randomize();
    `checkd(ok, 1);
    `checkd(outer.h1.arr.size(), outer.h1.n);

    // The member class still resizes its own arrays
    ok = holder.randomize();
    `checkd(ok, 1);
    `checkd(holder.arr.size(), holder.n);
    `checkd(holder.q.size(), 2);

    $write("*-* All Finished *-*\n");
    $finish;
  end
endmodule
