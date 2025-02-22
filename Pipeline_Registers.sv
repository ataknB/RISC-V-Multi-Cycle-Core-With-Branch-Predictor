module Decode_Register(
	input logic clk,
	input logic rst,
	
	input logic [31:0]normal_F,
	input logic [31:0]PC_out_F,
	input logic [31:0]InstructionMemory_out_F,
	

	input logic stall_DE,
	input logic flush_DE,
	
	input logic BP_decision_F,
	input logic BP_en_F,

	
	output logic BP_decision_DE,
	output logic [31:0]normal_DE,
	output logic [31:0]PC_out_DE,
	output logic [31:0]InstructionMemory_out_DE,
	output logic BP_en_DE
	);
	
	always_ff @(posedge clk, negedge rst)
	begin
		if(!rst || flush_DE)
			begin
				normal_DE <= 32'd0;
				PC_out_DE <= 32'd0;
				InstructionMemory_out_DE <= 32'd0;
				BP_decision_DE <= 1'd0;
				BP_en_DE <= 1'd0;
			end
		else
			if(stall_DE)
				begin
					normal_DE <= normal_DE;
					PC_out_DE <= PC_out_DE;
					InstructionMemory_out_DE <= InstructionMemory_out_DE;
					BP_decision_DE <= BP_decision_DE;
					BP_en_DE <= BP_en_DE;
				end
			else
				begin
					normal_DE <= normal_F;
					PC_out_DE <= PC_out_F;
					InstructionMemory_out_DE <= InstructionMemory_out_F;
					BP_decision_DE <= BP_decision_F;
					BP_en_DE <= BP_en_F;
				end
	end
endmodule

module Execute_Register (
    input logic clk,
    input logic rst,
	
    input logic [31:0] normal_DE,
    input logic [31:0] PC_out_DE,
    input logic [1:0] program_counter_controller_DE,
    input logic [4:0] shift_size_DE,
    input logic [4:0] rd_DE,
    input logic rf_write_en_DE,
    input logic mem_read_en_DE,
    input logic mem_write_en_DE,
    input logic [3:0] alu_op_DE,
    //input logic [31:0] alu_in1_DE,
   // input logic [31:0] alu_in2_DE,
    input logic JALR_en_DE,
    input logic JAL_en_DE,
    input logic [31:0] imm_sign_extender_out_DE,
	
	input logic [31:0]rd1_DE,
	input logic [31:0]rd2_DE,
	
	input logic [4:0]rs1_DE,
	input logic [4:0]rs2_DE,
	
	input logic sign_extender_en_DE,
	
	input logic flush_EX,
	input logic [2:0]load_type_DE,

	input logic BP_decision_DE,
	input logic BP_en_DE,
	
	output logic sign_extender_en_EX,
	
    output logic [31:0] normal_EX,
    output logic [31:0] PC_out_EX,
    output logic [1:0] program_counter_controller_EX,
    output logic [4:0] shift_size_EX,
    output logic [4:0] rd_EX,
    output logic rf_write_en_EX,
    output logic mem_read_en_EX,
    output logic mem_write_en_EX,
    output logic [3:0] alu_op_EX,
   // output logic [31:0] alu_in1_EX,
    //output logic [31:0] alu_in2_EX,
    output logic JALR_en_EX,
    output logic JAL_en_EX,
    output logic [31:0] imm_sign_extender_out_EX,
	
	output logic [31:0]rd1_EX,
	output logic [31:0]rd2_EX,
	output logic [4:0]rs1_EX,
	output logic [4:0]rs2_EX,
	
	output logic [2:0]load_type_EX,

	output logic BP_decision_EX,
	output logic BP_en_EX

);

    always_ff@ (posedge clk or negedge rst)
	begin
		
		if(!rst || flush_EX)
		begin
			normal_EX <= 32'd0;
			PC_out_EX <= 32'd0;
			program_counter_controller_EX <= 32'd0;
			shift_size_EX <= 32'd0;
			rd_EX <= 32'd0;
			rf_write_en_EX <= 32'd0;
			mem_read_en_EX <= 32'd0;
			mem_write_en_EX <= 32'd0;
			alu_op_EX <= 32'd0;
			//alu_in1_EX <= 32'd0;
			//alu_in2_EX <= 32'd0;
			JALR_en_EX <= 32'd0;
			JAL_en_EX <= 32'd0;
			load_type_EX <= 2'd0;
			imm_sign_extender_out_EX <= 32'd0;
			rd1_EX <= 32'd0;
			rd2_EX <= 32'd0;
			sign_extender_en_EX <= 1'b0;
			rs1_EX <= 5'd0;
			rs2_EX <= 5'd0;
			BP_decision_EX <= 1'd0;
			BP_en_EX <= 1'd0;
		end
		else
		begin
			normal_EX <= normal_DE;
			PC_out_EX <= PC_out_DE;
			program_counter_controller_EX <= program_counter_controller_DE;
			
			shift_size_EX <= shift_size_DE;
			rd_EX <= rd_DE;
			rf_write_en_EX <= rf_write_en_DE;
			mem_read_en_EX <= mem_read_en_DE;
			mem_write_en_EX <= mem_write_en_DE;
			alu_op_EX <= alu_op_DE;
			
			//alu_in1_EX <= alu_in1_DE;
			//alu_in2_EX <= alu_in2_DE;
			JALR_en_EX <= JALR_en_DE;
			JAL_en_EX <= JAL_en_DE;
			imm_sign_extender_out_EX <= imm_sign_extender_out_DE;
			rd1_EX <= rd1_DE;
			rd2_EX <= rd2_DE;
			load_type_EX <= load_type_DE;
			sign_extender_en_EX <= sign_extender_en_DE;
			rs1_EX <= rs1_DE;
			rs2_EX <= rs2_DE;
			BP_decision_EX <= BP_decision_DE;
			BP_en_EX <= BP_decision_DE;
		end
    end

endmodule

module Memory_Register (
    input logic clk,
    input logic rst,
    input logic [31:0]jump_EX,
    input logic [31:0]branch_EX,
    input logic branch_en_EX,
    input logic [31:0] normal_EX,
    input logic [31:0] PC_out_EX,
    input logic [1:0] program_counter_controller_EX,
    input logic alu_branch_control_EX,
    input logic [4:0] rd_EX,
    input logic rf_write_en_EX,
    input logic mem_read_en_EX,
    input logic mem_write_en_EX,
    input logic [31:0]rd2_EX,
    input logic [31:0]alu_out_EX,
	
	input logic [2:0]load_type_EX,
	
	output logic [31:0] alu_out_MEM,
    output logic [31:0]jump_MEM,
    output logic [31:0]branch_MEM,
    output logic branch_en_MEM,
    output logic [31:0] normal_MEM,
    output logic [31:0] PC_out_MEM,
    output logic [1:0] program_counter_controller_MEM,
    output logic alu_branch_control_MEM,
    output logic [4:0] rd_MEM,
    output logic rf_write_en_MEM,
    output logic mem_read_en_MEM,
    output logic mem_write_en_MEM,
	output logic [1:0]load_type_MEM,
    output logic [31:0] rd2_MEM
);

    always_ff @(posedge clk or negedge rst)
	begin
		if(!rst)
		begin
			alu_out_MEM <= 32'd0;
			jump_MEM <= 32'd0;
			branch_MEM <= 32'd0;
			branch_en_MEM <= 32'd0;
			normal_MEM <= 32'd0;
			PC_out_MEM <= 32'd0;
			program_counter_controller_MEM <= 32'd0;
			alu_branch_control_MEM <= 1'd0;
			rd_MEM <= 32'd0;
			rf_write_en_MEM <= 32'd0;
			mem_read_en_MEM <= 32'd0;
			mem_write_en_MEM <= 32'd0;
			rd2_MEM <= 32'd0;
			load_type_MEM <= 2'd0; 
		end
		
		else
		begin
			alu_out_MEM <= alu_out_EX;
			jump_MEM <= jump_EX;
			branch_MEM <= branch_EX;
			branch_en_MEM <= branch_en_EX;
			normal_MEM <= normal_EX;
			PC_out_MEM <= PC_out_EX;
			program_counter_controller_MEM <= program_counter_controller_EX;
			alu_branch_control_MEM <= alu_branch_control_EX;
			rd_MEM <= rd_EX;
			rf_write_en_MEM <= rf_write_en_EX;
			mem_read_en_MEM <= mem_read_en_EX;
			mem_write_en_MEM <= mem_write_en_EX;
			rd2_MEM <= rd2_EX;
			load_type_MEM <= load_type_EX;
		end
    end

endmodule

module WriteBack_Register (
    input logic clk,
    input logic rst,
    input logic branch_en_MEM,
    input logic [3:0] alu_branch_control_MEM,
    input logic mem_write_en_MEM,
    input logic mem_read_en_MEM,
    input logic [31:0] rd2_MEM,
    input logic [1:0] program_counter_controller_MEM,
    input logic [4:0] rd_MEM,
    input logic rf_write_en_MEM,
    input logic [31:0] wd_MEM,
    input logic [31:0] PC_out_MEM,
    input logic [31:0] normal_MEM,

    output logic [1:0] program_counter_controller_WB,
    output logic [4:0] rd_WB,
    output logic rf_write_en_WB,
    output logic [31:0] wd_WB,
    output logic [31:0] PC_out_WB,
    output logic [31:0] normal_WB
);

    always_ff @(posedge clk or negedge rst)
	begin
		if(!rst)
		begin
			program_counter_controller_WB <= 32'd0;
			rd_WB <= 32'd0;
			rf_write_en_WB <= 32'd0;
			wd_WB <= 32'd0;
			PC_out_WB <= 32'd0;
			normal_WB <= 32'd0;
		end
	
		else
		begin
			program_counter_controller_WB <= program_counter_controller_MEM;
			rd_WB <= rd_MEM;
			rf_write_en_WB <= rf_write_en_MEM;
			wd_WB <= wd_MEM;
			PC_out_WB <= PC_out_MEM;
			normal_WB <= normal_MEM;
		end
    end

endmodule