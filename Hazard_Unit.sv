module Hazard_Unit(
	input logic [4:0]rs1_DE,
	input logic [4:0]rs1_EX,
	
	input logic [4:0]rs2_DE,
	input logic [4:0]rs2_EX,
	
	input logic [4:0]rd_EX,
	input logic [4:0]rd_MEM,
	input logic [4:0]rd_WB,
	
	input logic [1:0]program_counter_controller_EX,
	input logic mem_read_en_EX,
	
	input logic rf_write_en_MEM,
	input logic rf_write_en_WB,
	
	input logic branch_control,
	input logic branch_decision,
	
	output logic [1:0]forward_mode_rs1,
	output logic [1:0]forward_mode_rs2,
	/*
		00 : normal input
		01 : from memory forward
		11 : from writeback forward
	*/

	output logic branch_correction,

	output logic stall_DE,
	output logic stall_F,
	output logic flush_EX,
	output logic flush_DE
);
	
	assign bracnch_predictor_flush = (branch_decision ^ branch_control);

	always_comb
	begin
		// Forwarding for rs1
		if ((rs1_EX == rd_MEM) && rf_write_en_MEM && rs1_EX != 5'd0) 
			forward_mode_rs1 = 2'b01; // Memory forwarding
		else if ((rs1_EX == rd_WB) && rf_write_en_WB && rs1_EX != 5'd0) 
			forward_mode_rs1 = 2'b11; // Writeback forwarding
		else 
			forward_mode_rs1 = 2'b00; // Normal case
		
		// Forwarding for rs2
		if ((rs2_EX == rd_MEM) && rf_write_en_MEM && rs2_EX != 5'd0) 
			forward_mode_rs2 = 2'b01; // Memory forwarding
		else if ((rs2_EX == rd_WB) && rf_write_en_WB && rs2_EX != 5'd0) 
			forward_mode_rs2 = 2'b11; // Writeback forwarding
		else 
			forward_mode_rs2 = 2'b00; // Normal case
		
		// Stall and Flush Logic for Load-use Hazard
		if ((mem_read_en_EX) && 
			((rs1_DE == rd_EX && rs1_DE != 5'd0) || (rs2_DE == rd_EX && rs2_DE != 5'd0)))
			begin
				stall_F = 1'd1; 
				stall_DE = 1'd1; 
				flush_EX = 1'd1;
			end    
		else
			begin
				stall_F = 1'd0; 
				stall_DE = 1'd0; 
				flush_EX = 1'd0;
			end 
		
		//Jump flushing
		//Branch Instruciton
		if(bracnch_predictor_flush)
			begin
				flush_EX = 1'b1;
				flush_DE = 1'b1;
				branch_correction = 1'b1;
			end
		
		else if(program_counter_controller_EX == 2'd2)
			begin
				flush_DE = 1'd1; 
				flush_EX = 1'd1;
				branch_correction = 1'b0;
			end

		else
			begin
				flush_EX = 1'b0;
				flush_DE = 1'b0;
				branch_correction = 1'b0;
			end
	end
	
endmodule
