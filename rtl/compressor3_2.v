module compressor3_2 (
    input  wire a, b, c,
    output w1, w2
);
    assign w1 = (a & b) | c;
    assign w2 = (a | b);
endmodule
