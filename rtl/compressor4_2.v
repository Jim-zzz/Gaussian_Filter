module compressor4_2 (
    input  wire a, b, c, d,
    output w1, w2
);
    assign w1 = (a & b) | c | d;
    assign w2 = (d & c) | (b | a);
endmodule
