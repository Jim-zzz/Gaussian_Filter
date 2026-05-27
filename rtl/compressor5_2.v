module compressor5_2 (
    input  a, b, c, d, e,
    output w1, w2
);
    assign w1 = (d | e) | a & (b | c) | (b & c);
    assign w2 = a | b | c;
endmodule
