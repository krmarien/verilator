// DESCRIPTION: Verilator: Verilog Test module
//
// This file ONLY is placed under the Creative Commons Public Domain.
// SPDX-FileCopyrightText: 2026 Wilson Snyder
// SPDX-License-Identifier: CC0-1.0

// constraint_mode() of a rand class member object's constraints, solved by the
// randomize() of the object holding the member

// verilog_format: off
`define stop $stop
`define checkd(gotv,expv) do if ((gotv) !== (expv)) begin $write("%%Error: %s:%0d:  got=%0d exp=%0d\n", `__FILE__,`__LINE__, (gotv), (expv)); `stop; end while(0);
// verilog_format: on

class Leaf;
  rand int x;
  rand int y;
  constraint c_x {x inside {[1 : 9]};}
  constraint c_y {y == 5;}
  static constraint c_s {y > 0;}
endclass

class Mid;
  rand Leaf leaf;
  function new();
    leaf = new;
  endfunction
endclass

class Top;
  rand Leaf leaf;
  rand Mid mid;
  rand int z;
  constraint c_z {z == 1;}
  function new();
    leaf = new;
    mid = new;
  endfunction
endclass

module t;
  initial begin
    automatic Mid mid = new;
    automatic Top top = new;
    automatic Leaf leaf = new;
    automatic bit outside;
    automatic int ok;

    ok = top.randomize();
    `checkd(ok, 1);
    `checkd(top.leaf.x inside {[1 : 9]}, 1'b1);
    `checkd(top.mid.leaf.x inside {[1 : 9]}, 1'b1);

    // Mid holds copies of the constraints of Leaf, as does Top through Mid
    mid.leaf.c_x.constraint_mode(0);
    outside = 0;
    repeat (20) begin
      ok = mid.randomize();
      `checkd(ok, 1);
      `checkd(mid.leaf.y, 5);
      if (!(mid.leaf.x inside {[1 : 9]})) outside = 1;
    end
    `checkd(outside, 1'b1);

    mid.leaf.c_x.constraint_mode(1);

    // A disabled constraint of a member, and of a member's member
    top.leaf.c_x.constraint_mode(0);
    top.mid.leaf.c_x.constraint_mode(0);
    outside = 0;
    repeat (20) begin
      ok = top.randomize();
      `checkd(ok, 1);
      `checkd(top.leaf.y, 5);
      `checkd(top.mid.leaf.y, 5);
      if (!(top.leaf.x inside {[1 : 9]}) && !(top.mid.leaf.x inside {[1 : 9]})) outside = 1;
    end
    `checkd(outside, 1'b1);

    // Re-enabled
    top.leaf.c_x.constraint_mode(1);
    top.mid.leaf.c_x.constraint_mode(1);
    repeat (5) begin
      ok = top.randomize();
      `checkd(ok, 1);
      `checkd(top.leaf.x inside {[1 : 9]}, 1'b1);
      `checkd(top.mid.leaf.x inside {[1 : 9]}, 1'b1);
    end

    // All constraints of one member object, and a static constraint
    top.leaf.constraint_mode(0);
    ok = top.randomize() with {leaf.y == 50;};
    `checkd(ok, 1);
    `checkd(top.leaf.y, 50);
    `checkd(top.mid.leaf.y, 5);
    `checkd(top.z, 1);
    top.leaf.constraint_mode(1);
    // A static constraint's mode is shared by all objects of the class
    top.leaf.c_s.constraint_mode(0);
    top.mid.leaf.c_y.constraint_mode(0);
    ok = top.randomize() with {mid.leaf.y == -2;};
    `checkd(ok, 1);
    `checkd(top.mid.leaf.y, -2);
    top.leaf.c_s.constraint_mode(1);
    ok = top.randomize() with {mid.leaf.y == -2;};
    `checkd(ok, 0);
    top.mid.leaf.c_y.constraint_mode(1);

    // The member class still applies the modes of its own randomize()
    leaf.c_y.constraint_mode(0);
    ok = leaf.randomize() with {y == 6;};
    `checkd(ok, 1);
    `checkd(leaf.y, 6);

    $write("*-* All Finished *-*\n");
    $finish;
  end
endmodule
