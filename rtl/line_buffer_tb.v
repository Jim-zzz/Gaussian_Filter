`timescale 1ns / 1ps

module test;

    // --- 參數設定 ---
    parameter WIDTH = 8;      // 修改：真實圖片通常是 8-bit (0~255)
    parameter DEPTH = 512;    // 圖片寬度
    parameter HEIGHT = 512;   // 圖片高度 (列數)

    // --- 輸入訊號 (Reg) ---
    reg i_clk;
    reg i_reset;
    reg i_valid;
    reg [WIDTH-1:0] i_data;

    // --- 輸出訊號 (Wire) ---
    wire [WIDTH-1:0] o_data0; // Top
    wire [WIDTH-1:0] o_data1; // Center
    wire [WIDTH-1:0] o_data2; // Bottom
    wire o_valid;
    
    // --- 產生波形檔 ---
    initial begin
        $fsdbDumpfile("wave.fsdb");
        $fsdbDumpvars(0, test);
    end

    // --- 實例化您的模組 (DUT) ---
    line_buffer #(
        .WIDTH(WIDTH),
        .DEPTH(DEPTH)
    ) uut (
        .i_clk(i_clk),
        .i_reset(i_reset),
        .i_valid(i_valid),
        .i_data(i_data),
        .o_data0(o_data0),
        .o_data1(o_data1),
        .o_data2(o_data2),
        .o_valid(o_valid)
    );

    // --- 產生時脈 (10ns週期 = 100MHz) ---
    always #5 i_clk = ~i_clk;

    // --- 測試變數 ---
    integer row, col; // 用來跑 512x512 的迴圈
    integer i;        // 用來跑 dummy 迴圈

    initial begin
        // 1. 初始化
        i_clk   = 0;
        i_reset = 1;
        i_valid = 0;
        i_data  = 0;

        // 2. 重置系統
        #20;
        @(negedge i_clk);
        i_reset = 0;
        #20;

        $display("--- Simulation Start: 512x512 Image ---");

        // 3. 開始輸入完整圖片 (512 x 512)
        // 使用巢狀迴圈模擬真實的 X, Y 掃描
        for (row = 0; row < HEIGHT; row = row + 1) begin
            
            $display("Starting Row: %d at Time: %t", row, $time); // 每一行提示一次就好

            for (col = 0; col < DEPTH; col = col + 1) begin
                @(negedge i_clk); // 在負緣送資料，確保 Setup Time
                i_valid = 1;
                
                // --- 造數據 ---
                // 這裡做一個簡單的漸層效果: (行+列) % 256
                // 這樣你在波形圖上會看到鋸齒狀的數據，很容易除錯
                i_data <= (col + row) % 256; 
            end
        end

        // 4. [關鍵!] 送入 Dummy Row (Padding/Flush)
        // 為了把最後一行 (Row 511) 從 Line Buffer 擠出來
        $display("--- Sending Dummy Row (Flush) ---");
        for (i = 0; i < DEPTH; i = i + 1) begin
            @(negedge i_clk);
            i_valid = 1;
            i_data  <= 0; // 送 0 進去推擠
        end

        // 5. 停止輸入
        @(negedge i_clk);
        i_valid = 0;
        i_data  = 0;
        
        // 6. 再多跑一點時間讓最後的數據吐完
        #500;
        $display("--- Simulation End ---");
        $finish;
    end

    // --- 監控輸出 ---
    // 為了避免 Console 被 26萬行訊息塞爆，這裡只在波形檔觀察
    // 或者你可以設定只印出特定幾行
    /*
    always @(negedge i_clk) begin
        if (o_valid) begin
            // 這裡可以選擇性印出，例如只印第 256 列的數據
            // if (uut.row_cnt == 256) ...
        end
    end
    */

endmodule
