module PC(
	input logic	clk, 
	input logic rst,
	
	input logic stall_F,
	
	input logic [31:0]PC_in,
	output logic [31:0]PC_out
);

	always_ff @(posedge clk or negedge rst)
	begin
		
		if(!rst)
		begin
			PC_out <= 32'd0;
		end
		
		else
			if(stall_F)
				begin
					PC_out <= PC_out;
				end
			else
				begin
					PC_out <= PC_in;
				end
	end
endmodule