module div21 (
    input  wire [15:0] sum_result,  // 卷積後的總和
    output wire [7:0]  pixel_out    // 除完後的結果 (回歸 0~255)
);

    wire [23:0] temp;

    // 1. 乘以 195
    assign temp = sum_result * 8'd195;

    // 2. 右移 12 (相當於除以 4096)
    assign pixel_out = temp[19:12]; 

endmodule
