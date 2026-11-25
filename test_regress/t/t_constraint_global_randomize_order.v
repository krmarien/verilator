// DESCRIPTION: Verilator: Verilog Test module
//
// This file ONLY is placed under the Creative Commons Public Domain.
// SPDX-FileCopyrightText: 2026 Wilson Snyder
// SPDX-License-Identifier: CC0-1.0

// The constraints of a rand class member object also apply when the member's class
// has randomize() called on it before the class holding the member

// verilog_format: off
`define stop $stop
`define checkd(gotv,expv) do if ((gotv) !== (expv)) begin $write("%%Error: %s:%0d:  got=%0d exp=%0d\n", `__FILE__,`__LINE__, (gotv), (expv)); `stop; end while(0);
// verilog_format: on

class Holder;
  rand int n;
  rand int k;
  constraint c_n {
    n inside {[2 : 4]};
    k == n;
  }
endclass

class Conflict;
  rand Holder h;
  constraint c_h {h.n == 5;}
  function new();
    h = new;
  endfunction
endclass

class Agree;
  rand Holder h;
  constraint c_h {h.n == 3;}
  function new();
    h = new;
  endfunction
endclass

module t;
  initial begin
    automatic Holder holder = new;
    automatic Conflict conflict = new;
    automatic Agree agree = new;
    automatic int ok;

    ok = holder.randomize();
    `checkd(ok, 1);
    `checkd(holder.k, holder.n);

    ok = conflict.randomize();
    `checkd(ok, 0);

    ok = agree.randomize();
    `checkd(ok, 1);
    `checkd(agree.h.n, 3);
    `checkd(agree.h.k, 3);

    $write("*-* All Finished *-*\n");
    $finish;
  end
endmodule
