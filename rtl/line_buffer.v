`timescale 1ns/1ps

module line_buffer #(
	parameter WIDTH = 8,
	parameter DEPTH = 512
)(
	input  i_clk,
	input  i_reset,
	input  i_valid,
	input  [WIDTH-1:0] i_data,
	output [WIDTH-1:0] o_data0,
	output [WIDTH-1:0] o_data1,
	output [WIDTH-1:0] o_data2,
	output o_valid

);

reg [WIDTH-1:0] line0  [0:DEPTH-1];
reg [WIDTH-1:0] line1  [0:DEPTH-1];
reg [8:0]  ptr;
reg [11:0] counter;
reg [18:0] counter2;
reg data_valid;
reg en;
reg [WIDTH-1:0] r_data0;
reg [WIDTH-1:0] r_data1;
reg [WIDTH-1:0] r_data2;
reg [WIDTH:0] col_cnt;
reg [WIDTH:0] row_cnt;
wire top_row;
wire bottom_row;


// mem address
always @(posedge i_clk) begin
	if (i_reset) begin
		ptr <= 0;
	end else if (i_valid || o_valid) begin
		ptr <= ptr + 1;
	end
end



// counter
always @(posedge i_clk) begin
	if (i_reset) begin
		counter <= 0;
	end else if (i_valid || o_valid) begin
		if (counter == 12'd1536) begin
			counter <= 1;		
		end
		else begin
			counter <= counter + 1;
		end
	end
end
// output counter
always @(posedge i_clk) begin
	if (i_reset) begin
		en <= 0;
	end else if (i_valid) begin
		en <= 1;
	end
end

always @(posedge i_clk) begin
	if (i_reset) begin
		counter2 <= 0;
	end else if (en) begin
		counter2 <= counter2 + 1;
	end 
end

assign o_valid = (counter2 >= 19'd512 && counter2 <= 19'd262655);
// row and col counter
always @(posedge i_clk) begin
	if (i_reset) begin
		col_cnt <= 0;
		row_cnt <= 0;
	end else if (o_valid) begin
		if (col_cnt == 9'd511) begin
			col_cnt <= 0;
			if (row_cnt < 9'd511) row_cnt <= row_cnt + 1;
		end else begin
			col_cnt <= col_cnt + 1;
		end
	end
end

assign top_row = (row_cnt == 0);
assign bottom_row = (row_cnt == 9'd511);

always @(posedge i_clk) begin
	if (i_reset) begin
		r_data0 <= 0;
		r_data1 <= 0;
		r_data2 <= 0;
	end	else begin
		// write data
		line0[ptr] <= i_data;
		line1[ptr] <= line0[ptr];
		// read data
		r_data0 <= line1[ptr];
		r_data1 <= line0[ptr];
		r_data2 <= i_data;
	end
		
end

assign o_data0 = (o_valid && !top_row) ? r_data0 : 0;
assign o_data1 = o_valid ? r_data1 : 0;
assign o_data2 = (o_valid && !bottom_row) ? r_data2 : 0;



endmodule
	
	


