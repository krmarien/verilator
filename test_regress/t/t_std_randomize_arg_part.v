// DESCRIPTION: Verilator: Verilog Test module
//
// This file ONLY is placed under the Creative Commons Public Domain.
// SPDX-FileCopyrightText: 2026 Wilson Snyder
// SPDX-License-Identifier: CC0-1.0

// A std::randomize() argument that is part of a variable: the rest of the
// variable keeps its value and is state in the with clause

// verilog_format: off
`define stop $stop
`define checkd(gotv,expv) do if ((gotv) !== (expv)) begin $write("%%Error: %s:%0d:  got=%0d exp=%0d\n", `__FILE__,`__LINE__, (gotv), (expv)); `stop; end while(0);
// verilog_format: on

typedef struct {
  bit [7:0] a;
  bit [7:0] b;
} pair_t;

class Obj;
  int x;
  int y;
endclass

module t;
  bit [62:0] unp[10];
  bit [15:0] dyn[];
  bit [15:0] dyn2[];
  pair_t s;
  pair_t sa[3];
  Obj o;
  Obj p;
  int r;

  initial begin
    automatic int i = 0;
    automatic int j = 1;
    foreach (unp[k]) unp[k] = 63'(k);
    dyn = '{100, 200, 300};
    dyn2 = '{1, 2, 3};
    s = '{a: 1, b: 9};
    sa = '{'{1, 2}, '{3, 4}, '{5, 6}};
    o = new;
    o.y = 41;
    p = new;
    p.x = 7;

    r = std::randomize(unp[i]) with { unp[i] == unp[j] + 63'd5; };
    `checkd(r, 1);
    `checkd(unp[i], 6);
    `checkd(unp[j], 1);

    r = std::randomize(unp[i + 2]) with { unp[i + 2] == unp[j] + 63'd7; };
    `checkd(r, 1);
    `checkd(unp[2], 8);

    r = std::randomize(dyn[i]) with { dyn[i] == dyn[j] + 16'(dyn.size()) + dyn2[i] + 16'd1; };
    `checkd(r, 1);
    `checkd(dyn[i], 205);
    `checkd(dyn[j], 200);

    r = std::randomize(s.a) with { s.a == s.b + 8'd1; };
    `checkd(r, 1);
    `checkd(s.a, 10);
    `checkd(s.b, 9);

    r = std::randomize(sa[i].a) with { sa[i].a == sa[j].b + sa[2].a - 8'd4; };
    `checkd(r, 1);
    `checkd(sa[i].a, 5);
    `checkd(sa[i].b, 2);

    r = std::randomize(o.x) with { o.x == o.y + p.x - 6; };
    `checkd(r, 1);
    `checkd(o.x, 42);
    `checkd(o.y, 41);
    `checkd(p.x, 7);

    $write("*-* All Finished *-*\n");
    $finish;
  end
endmodule
