module gaussian_filter #(
	parameter WIDTH = 8 )(
	input   i_clk,
	input   i_reset,
	input   i_valid,
	input   [WIDTH-1:0] i_data,
	output  [WIDTH-1:0] o_data,
	output  o_valid
	
);




reg [WIDTH-1:0] r1_1, r1_2, r1_3;
reg [WIDTH-1:0] r2_1, r2_2, r2_3;
reg [WIDTH-1:0] r3_1, r3_2, r3_3;
reg [WIDTH-1:0] sum;
reg [WIDTH-1:0] temp_sum;
reg [18:0] counter;
reg i_en;
reg [WIDTH:0] f_col_cnt;
wire left_edge;
wire right_edge;
wire o_en;
wire [WIDTH-1:0] o_data0, o_data1, o_data2;
wire [WIDTH-1:0] w1_1, w1_2, w1_3;
wire [WIDTH-1:0] w2_1, w2_2, w2_3;
wire [WIDTH-1:0] w3_1, w3_2, w3_3;
wire [WIDTH*2-1:0] m1_1, m1_2, m1_3;
wire [WIDTH*2-1:0] m2_1, m2_2, m2_3;
wire [WIDTH*2-1:0] m3_1, m3_2, m3_3;


line_buffer #(.WIDTH(WIDTH), .DEPTH(512)) l0 (.i_clk(i_clk), .i_reset(i_reset), .i_valid(i_valid), .i_data(i_data), .o_data0(o_data0), .o_data1(o_data1), .o_data2(o_data2), .o_valid(o_en));
dadda_tree d0 (.x(w1_1), .y(8'd1), .z(m1_1));
dadda_tree d1 (.x(w1_2), .y(8'd2), .z(m1_2));
dadda_tree d2 (.x(w1_3), .y(8'd1), .z(m1_3));
dadda_tree d3 (.x(w2_1), .y(8'd1), .z(m2_1));
dadda_tree d4 (.x(w2_2), .y(8'd5), .z(m2_2));
dadda_tree d5 (.x(w2_3), .y(8'd2), .z(m2_3));
dadda_tree d6 (.x(w3_1), .y(8'd1), .z(m3_1));
dadda_tree d7 (.x(w3_2), .y(8'd2), .z(m3_2));
dadda_tree d8 (.x(w3_3), .y(8'd1), .z(m3_3));



always @(posedge i_clk) begin
	if (i_reset) begin
		f_col_cnt <= 0;
	end else if (o_en) begin
		if (f_col_cnt == 511) 
			f_col_cnt <= 0;
		else 
			f_col_cnt <= f_col_cnt + 1;
	end
end

assign left_edge  = (f_col_cnt == 2);
assign right_edge = (f_col_cnt == 1);

assign w1_1 = (left_edge) ? 0 : r1_1;
assign w2_1 = (left_edge) ? 0 : r2_1;
assign w3_1 = (left_edge) ? 0 : r3_1;

assign w1_2 = r1_2;
assign w2_2 = r2_2;
assign w3_2 = r3_2;

assign w1_3 = (right_edge) ? 0 : r1_3;
assign w2_3 = (right_edge) ? 0 : r2_3;
assign w3_3 = (right_edge) ? 0 : r3_3;


always @(posedge i_clk) begin
	if (i_reset) begin
		r1_1 <= 0;
		r2_1 <= 0;
		r3_1 <= 0;
		r1_2 <= 0;
		r2_2 <= 0;
		r3_2 <= 0;
		r1_3 <= 0;
		r2_3 <= 0;
		r3_3 <= 0;

	end else if(o_en || o_valid) begin
		r1_1 <= r1_2;
		r2_1 <= r2_2;
		r3_1 <= r3_2;
		r1_2 <= r1_3;
		r2_2 <= r2_3;
		r3_2 <= r3_3;
		r1_3 <= o_data0;
		r2_3 <= o_data1;
		r3_3 <= o_data2;
//		sum <= ({4'd0, w1_1} + 2*{3'd0, w1_2} + {4'd0, w1_3} + 2*{3'd0, w2_1} + 4*{2'd0, w2_2} + 2*{3'd0, w2_3} + {4'd0, w3_1} + 2*{3'd0, w3_2} + {4'd0, w3_3}) >> 4;
		sum <= (m1_1 + m1_2 + m1_3 + m2_1 + m2_2 + m2_3 + m3_1 + m3_2 + m3_3) >> 4;
	end
end


always @(posedge i_clk) begin
	if (i_reset) begin
		i_en <= 0;
	end	else if (o_en) begin
		i_en <= 1;
	end else if (counter == 19'd262145) begin
		i_en <= 0;
	end
end
always @(posedge i_clk) begin
	if (i_reset) begin
		counter <= 0;
	end else if (i_en) begin
		counter <= counter + 1;
		if (counter == 19'd262145) begin
			counter <= 0;
		end
	end
end

assign o_valid = (counter >= 19'd2 && counter <= 19'd262145);
assign o_data = o_valid ? sum : 0;

endmodule
