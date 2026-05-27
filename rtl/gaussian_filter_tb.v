`timescale 1ns/1ps

module test;

    // --- 參數定義 ---
    parameter WIDTH = 8;      // 修正：真實圖片處理通常是 8-bit (0~255)
    parameter IMG_W = 512;    // 圖片寬度
    parameter IMG_H = 512;    // 圖片高度
    // 總像素數 = 262,144

    // --- 輸入訊號 (Reg) ---
    reg i_clk;
    reg i_reset;
    reg i_valid;
    reg [WIDTH-1:0] i_data;

    // --- 輸出訊號 (Wire) ---
    wire [WIDTH-1:0] o_data;
    wire o_valid; 

    // --- 變數 ---
    integer row, col; // 用來跑雙層迴圈
    integer i;        // 用來跑 dummy 迴圈

    // 1. 實例化待測模組 (DUT)
    gaussian_filter #(
        .WIDTH(WIDTH)
    ) u_gaussian_filter (
        .i_clk(i_clk),
        .i_reset(i_reset),
        .i_valid(i_valid),
        .i_data(i_data),
        .o_data(o_data),
        .o_valid(o_valid)
    );

    // 2. 產生時脈 (10ns 週期 = 100MHz)
    initial begin
        i_clk = 0;
        forever #5 i_clk = ~i_clk;
    end

    // 3. 主要測試邏輯
    initial begin
        // --- 初始化 ---
        $fsdbDumpfile("wave.fsdb"); 
        $fsdbDumpvars(0, test);
        
        i_reset = 1;
        i_valid = 0;
        i_data  = 0;

        // --- Reset 釋放 ---
        #20;
        @(negedge i_clk); 
        i_reset = 0;
        #20;

        $display("--- Start Simulation: 512x512 Image ---");

        // --- [重點] 送入完整圖片資料 (512 * 512) ---
        for (row = 0; row < IMG_H; row = row + 1) begin
            
            // 每一列開始時印出時間，方便確認進度 (不然跑太久會以為當機)
            if (row % 64 == 0) // 每 64 行印一次就好
                $display("Processing Row: %d at Time: %t", row, $time);

            for (col = 0; col < IMG_W; col = col + 1) begin
                @(negedge i_clk); // 在負緣送資料 (Setup Time)
                i_valid = 1;
                
                // 造資料：產生一個斜向漸層 (0~255循環)
                // 這樣在波形上很好除錯，如果數據錯位一眼就看得到
                i_data  = (row + col) % 256; 
            end
        end

        // --- [重點] Flush Buffer (送入 Dummy Row) ---
        // 圖片送完了，但 Line Buffer 裡面還有最後一行的資料卡著
        // 我們必須繼續送 i_valid = 1 (送 0 進去) 把舊資料推出來
        $display("--- Sending Dummy Row to Flush Pipeline ---");
        
        for (i = 0; i < IMG_W; i = i + 1) begin // 多送 512 個 cycle
            @(negedge i_clk);
            i_valid = 1;
            i_data  = 0; 
        end

        // --- 傳輸結束 ---
        @(negedge i_clk);
        i_valid = 0;
        i_data  = 0;

        // 再多跑一點時間觀察最後的波形
        #500;
        
        $display("--- Simulation Finished Successfully ---");
        $finish;
    end

    // 4. 監控輸出 (Optional)
    // 為了避免 Log 太大，這裡可以設定只在 output valid 變成 0 (結束) 的時候印出來
    /*
    always @(negedge i_clk) begin
        if (o_valid) begin
            // $display("Out: %d", o_data);
        end
    end
    */

endmodule
