`timescale 1ns/1ps
module dadda_tree (

    input  [7:0] x,
    input  [7:0] y,
    output [15:0] z
);

wire [7:0] pp0, pp1, pp2, pp3, pp4, pp5, pp6, pp7;
wire s1_1, s1_2, s1_3, s1_4, s1_5, s1_6, s1_7, s1_8, s1_9;
wire s2_1, s2_2, s2_3, s2_4, s2_5, s2_6, s2_7, s2_8, s2_9, s2_10, s2_11, s2_12, s2_13, s2_14, s2_15, s2_16, s2_17, s2_18, s2_19, s2_20, s2_21, s2_22;
wire [14:0] row1, row2;

partial_product p0 (
    .x(x),
    .y(y),
    .pp0(pp0),
    .pp1(pp1),
    .pp2(pp2),
    .pp3(pp3),
    .pp4(pp4),
    .pp5(pp5),
    .pp6(pp6),
    .pp7(pp7)
);

compressor2_1 com1_1 (.a(pp0[5]), .b(pp1[4]), .w1(s1_1));
compressor2_1 com1_2 (.a(pp0[6]), .b(pp1[5]), .w1(s1_2));
compressor2_1 com1_3 (.a(pp2[4]), .b(pp3[3]), .w1(s1_3));
compressor2_1 com1_4 (.a(pp0[7]), .b(pp1[6]), .w1(s1_4));
compressor2_1 com1_5 (.a(pp2[5]), .b(pp3[4]), .w1(s1_5));
compressor2_1 com1_6 (.a(pp4[3]), .b(pp5[2]), .w1(s1_6));
compressor2_1 com1_7 (.a(pp1[7]), .b(pp2[6]), .w1(s1_7));
compressor2_1 com1_8 (.a(pp3[5]), .b(pp4[4]), .w1(s1_8));
compressor2_1 com1_9 (.a(pp2[7]), .b(pp3[6]), .w1(s1_9));

compressor3_2 com2_1  (.a(pp0[2]), .b(pp1[1]), .c(pp2[0]), .w1(s2_1),  .w2(s2_2));
compressor4_2 com2_2  (.a(pp0[3]), .b(pp1[2]), .c(pp2[1]), .d(pp3[0]), .w1(s2_3),  .w2(s2_4));
compressor5_2 com2_3  (.a(pp0[4]), .b(pp1[3]), .c(pp2[2]), .d(pp3[1]), .e(pp4[0]), .w1(s2_5),  .w2(s2_6));
compressor5_2 com2_4  (.a(s1_1),   .b(pp2[3]), .c(pp3[2]), .d(pp4[1]), .e(pp5[0]), .w1(s2_7),  .w2(s2_8));
compressor5_2 com2_5  (.a(s1_2),   .b(s1_3),   .c(pp4[2]), .d(pp5[1]), .e(pp6[0]), .w1(s2_9),  .w2(s2_10));
compressor5_2 com2_6  (.a(s1_4),   .b(s1_5),   .c(s1_6),   .d(pp6[1]), .e(pp7[0]), .w1(s2_11), .w2(s2_12));
compressor5_2 com2_7  (.a(s1_7),   .b(s1_8),   .c(pp5[3]), .d(pp6[2]), .e(pp7[1]), .w1(s2_13), .w2(s2_14));
compressor5_2 com2_8  (.a(s1_9),   .b(pp4[5]), .c(pp5[4]), .d(pp6[3]), .e(pp7[2]), .w1(s2_15), .w2(s2_16));
compressor5_2 com2_9  (.a(pp3[7]), .b(pp4[6]), .c(pp5[5]), .d(pp6[4]), .e(pp7[3]), .w1(s2_17), .w2(s2_18));
compressor4_2 com2_10 (.a(pp4[7]), .b(pp5[6]), .c(pp6[5]), .d(pp7[4]), .w1(s2_19), .w2(s2_20));
compressor3_2 com2_11 (.a(pp5[7]), .b(pp6[6]), .c(pp7[5]), .w1(s2_21), .w2(s2_22));

assign row1 = {pp7[7], pp6[7], s2_21, s2_19, s2_17, s2_15, s2_13, s2_11, s2_9, s2_7, s2_5, s2_3, s2_1, pp0[1], pp0[0]};
assign row2 = {1'b0,   pp7[6], s2_22, s2_20, s2_18, s2_16, s2_14, s2_12, s2_10, s2_8, s2_6, s2_4, s2_2, pp1[0], 1'b0};

//sle_adder #(.WIDTH(16)) sle0 (.x(row1), .y(row2), .z(z));
assign z = row1 + row2;

endmodule
