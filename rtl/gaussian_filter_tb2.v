`timescale 1ns/1ps

module test;

    // --- 參數定義 ---
    parameter WIDTH = 8;      
    parameter IMG_W = 512;    
    parameter IMG_H = 512;    
    parameter TOTAL_PIXELS = IMG_W * IMG_H; // 262144

    // --- 輸入訊號 ---
    reg i_clk;
    reg i_reset;
    reg i_valid;
    reg [WIDTH-1:0] i_data;

    // --- 輸出訊號 ---
    wire [WIDTH-1:0] o_data;
    wire o_valid; 

    // --- 檔案處理變數 ---
    reg [WIDTH-1:0] img_mem [0:TOTAL_PIXELS-1]; // 模擬用的記憶體，裝整張圖
    integer row, col; 
    integer i;        // flush 用
    integer ptr;      // 記憶體指標 (pointer)
    integer file_out; // 輸出檔案 handler

    // 1. 實例化 DUT
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

    // 2. Clock 產生
    initial begin
        i_clk = 0;
        forever #5 i_clk = ~i_clk;
    end

    // 3. 主要測試邏輯
    initial begin
        // --- 設定波形檔 ---
        $fsdbDumpfile("wave.fsdb"); 
        $fsdbDumpvars(0, test);

        // --- [關鍵步驟] 讀取外部 txt 檔案 ---
        // 請確保 img_data.txt 已經在你的模擬資料夾中
        // 格式：16 進位 (Hex)，例如: FF, A0, 05...
        // 如果你的 MATLAB 是存十進位，請把 $readmemh 改成 $readmemb (二進位) 或是要在 MATLAB 轉成 Hex
        $readmemh("img_data.txt", img_mem);
        
        // 開啟輸出檔案 (用來存運算結果)
        file_out = $fopen("output_result.txt", "w");

        // --- 初始化 ---
        i_reset = 1;
        i_valid = 0;
        i_data  = 0;
        ptr     = 0; // 指標歸零

        // --- Reset ---
        #20;
        @(negedge i_clk); 
        i_reset = 0;
        #20;

        $display("--- Start Simulation: Reading from img_data.txt ---");

        // --- 送入圖片資料 ---
        for (row = 0; row < IMG_H; row = row + 1) begin
            
            if (row % 64 == 0) 
                $display("Processing Row: %d / %d", row, IMG_H);

            for (col = 0; col < IMG_W; col = col + 1) begin
                @(negedge i_clk);
                i_valid = 1;
                
                // [修改處] 從記憶體讀取真實數據
                i_data = img_mem[ptr]; 
                
                // 指標往下移動
                ptr = ptr + 1;
            end
        end

        // --- Flush Buffer (Dummy Row) ---
        $display("--- Sending Dummy Row to Flush Pipeline ---");
        
        for (i = 0; i < IMG_W; i = i + 1) begin 
            @(negedge i_clk);
            i_valid = 1;
            i_data  = 0; 
        end

        // --- 結束傳輸 ---
        @(negedge i_clk);
        i_valid = 0;
        i_data  = 0;

        // 等待所有數據輸出完畢
        #1000;
        
        // 關閉檔案
        $fclose(file_out);
        $display("--- Simulation Finished. Result saved to output_result.txt ---");
        $finish;
    end

    // --- 4. [新增] 將結果寫入檔案 ---
    // 這樣你才能用 MATLAB 驗證結果
    always @(posedge i_clk) begin
        if (o_valid) begin
            // 寫入 output_result.txt，使用 16 進位 (%02x) 格式
            $fdisplay(file_out, "%02x", o_data);
        end
    end

endmodule
