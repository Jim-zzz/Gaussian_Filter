`timescale 1ns/1ps
module partial_product (
    input  [7:0] x,   // multiplicand
    input  [7:0] y,   // multiplier
    output [7:0] pp0,
    output [7:0] pp1,
    output [7:0] pp2,
    output [7:0] pp3,
    output [7:0] pp4,
    output [7:0] pp5,
    output [7:0] pp6,
    output [7:0] pp7
);

    // 每列: 若 y[i]=1 則整列等於 x, 否則全 0
    assign pp0 = ({8{y[0]}} & x);
    assign pp1 = ({8{y[1]}} & x);
    assign pp2 = ({8{y[2]}} & x);
    assign pp3 = ({8{y[3]}} & x);
    assign pp4 = ({8{y[4]}} & x);
    assign pp5 = ({8{y[5]}} & x);
    assign pp6 = ({8{y[6]}} & x);
    assign pp7 = ({8{y[7]}} & x);

endmodule
