// DESCRIPTION: Verilator: Verilog Test module
//
// This file ONLY is placed under the Creative Commons Public Domain.
// SPDX-FileCopyrightText: 2026 Wilson Snyder
// SPDX-License-Identifier: CC0-1.0

// The size of a rand associative array is not randomized, so is state in a
// constraint (IEEE 1800-2023 18.4), and its elements at the current keys are random

// verilog_format: off
`define stop $stop
`define checkd(gotv,expv) do if ((gotv) !== (expv)) begin $write("%%Error: %s:%0d:  got=%0d exp=%0d\n", `__FILE__,`__LINE__, (gotv), (expv)); `stop; end while(0);
// verilog_format: on

class Sized;
  rand int values[int];
  rand int count;
  constraint c_size {
    values.size() == 2;
    count == values.size() + 1;
  }
endclass

class Elements;
  rand int values[int];
  rand bit [7:0] names[string];
  constraint c_values {
    values[1] == 31;
    names["b"] == 8'd7;
  }
endclass

class Derived extends Sized;
  constraint c_value {values[9] == 5;}
endclass

module t;
  initial begin
    automatic Sized sized = new;
    automatic Elements elements = new;
    automatic Derived derived = new;
    automatic int ok;

    sized.values[5] = 0;
    sized.values[9] = 0;
    ok = sized.randomize();
    `checkd(ok, 1);
    `checkd(sized.values.size(), 2);
    `checkd(sized.count, 3);
    ok = sized.randomize() with {values.size() == 3;};
    `checkd(ok, 0);
    sized.values[11] = 0;
    ok = sized.randomize();
    `checkd(ok, 0);
    `checkd(sized.values.size(), 3);

    elements.values[1] = 0;
    elements.values[2] = 0;
    elements.names["a"] = 0;
    elements.names["b"] = 0;
    repeat (5) begin
      ok = elements.randomize();
      `checkd(ok, 1);
      `checkd(elements.values.size(), 2);
      `checkd(elements.values[1], 31);
      `checkd(elements.names["b"], 7);
    end

    derived.values[5] = 0;
    derived.values[9] = 0;
    ok = derived.randomize();
    `checkd(ok, 1);
    `checkd(derived.values[9], 5);
    `checkd(derived.count, 3);

    $write("*-* All Finished *-*\n");
    $finish;
  end
endmodule
