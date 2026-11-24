// DESCRIPTION: Verilator: Verilog Test module
//
// This file ONLY is placed under the Creative Commons Public Domain.
// SPDX-FileCopyrightText: 2026 Wilson Snyder
// SPDX-License-Identifier: CC0-1.0

// An index wider than the array's index is out of range when its upper bits are
// set, rather than selecting the element its low bits name (IEEE 1800-2023 7.4.6)

// verilog_format: off
`define stop $stop
`define checkh(gotv,expv) do if ((gotv) !== (expv)) begin $write("%%Error: %s:%0d:  got=%0x exp=%0x\n", `__FILE__,`__LINE__, (gotv), (expv)); `stop; end while(0);
// verilog_format: on

module t;
  int odd[3] = '{10, 11, 12};
  int pow2[4] = '{20, 21, 22, 23};
  int ranged[1:3] = '{31, 32, 33};
  int grid[2][3] = '{'{40, 41, 42}, '{43, 44, 45}};
  int idx;
  int sum;

  initial begin
    idx = 4;  // Low bits select element 0
    `checkh(odd[idx], 0);
    idx = 5;
    `checkh(pow2[idx], 0);
    idx = 2;
    `checkh(pow2[idx], 22);
    idx = 5;  // Low bits select element 1
    `checkh(ranged[idx], 0);
    idx = 3;
    `checkh(ranged[idx], 33);
    idx = 4;
    `checkh(grid[1][idx], 0);
    // Out-of-range writes are ignored
    idx = 4;
    odd[idx] = 99;
    pow2[idx] = 99;
    sum = 0;
    foreach (odd[i]) sum += odd[i];
    foreach (pow2[i]) sum += pow2[i];
    `checkh(sum, 10 + 11 + 12 + 20 + 21 + 22 + 23);
    $write("*-* All Finished *-*\n");
    $finish;
  end
endmodule
