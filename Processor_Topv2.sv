module Processor_Top #(
	parameter WIDTH = 32
	)(
	input logic rst,
	input logic clk
);
	
	//logic [WIDTH-1:0]jump; 
	logic [WIDTH-1:0]jump_EX; 
	logic [WIDTH-1:0]jump_MEM; 
	
	//logic [WIDTH-1:0]branch_;
	logic [WIDTH-1:0]branch_EX;
	logic [WIDTH-1:0]branch_MEM;
	
	//logic [WIDTH-1:0]normal;
	logic [WIDTH-1:0]normal_F;
	logic [WIDTH-1:0]normal_DE;
	logic [WIDTH-1:0]normal_EX;
	logic [WIDTH-1:0]normal_MEM;
	logic [WIDTH-1:0]normal_WB;

	logic [WIDTH-1:0]PC_in;
	
	//logic [WIDTH-1:0]PC_out;
	logic [WIDTH-1:0]PC_out_F;
	logic [WIDTH-1:0]PC_out_DE;
	logic [WIDTH-1:0]PC_out_EX;
	logic [WIDTH-1:0]PC_out_MEM;
	logic [WIDTH-1:0]PC_out_WB;
	
	//logic [1:0]program_counter_controller;
	logic [1:0]program_counter_controller_DE;
	logic [1:0]program_counter_controller_EX;
	logic [1:0]program_counter_controller_MEM;
	logic [1:0]program_counter_controller_WB;
	
	//logic alu_branch_control;
	logic alu_branch_control_EX;
	logic alu_branch_control_MEM;
	
	//logic branch_en;
	logic branch_en;
	
	//Hazard Signals
	logic stall_F;
	logic stall_DE;
	logic flush_EX;
	
	logic [1:0]forward_mode_rs2;
	logic [1:0]forward_mode_rs1;
	
	assign branch_en = alu_branch_control_MEM && program_counter_controller_MEM[1] && program_counter_controller_MEM[0];
	

	Kogge_Stone PC_normal(
		.in0(PC_out_F),
		.in1(32'd4),
		
		.sub_en(1'b0),
		.out(normal_F)
	);
	
	logic branch_correction;

	MUX_PC MUX_PC(
		.jump(jump_EX),
		.branch(wire_x),//branch_MEM
		.normal_F(normal_F),
		.normal_EX(normal_EX),
		
		.branch_correction(branch_correction),

		.program_counter_controller(program_counter_controller_EX),
		.branch_en_F(BP_decision_F),
		.branch_en_EX(branch_en_EX),
		
		.out(PC_in)
	);

	PC PC(
		.clk(clk),
		.rst(rst),
		
		.stall_F(stall_F),
		
		.PC_in(PC_in),
		.PC_out(PC_out_F)
	);
	
	//assign PC_out_F = x + 32'd4;
	
	//logic [WIDTH-1:0]InstructionMemory_out;
	logic [WIDTH-1:0]InstructionMemory_out_F;
	logic [WIDTH-1:0]InstructionMemory_out_DE;

	Instruction_Memory Instruction_Memory_(
        .Program_counter_IM(PC_out_F),          
        .Instruction_IM(InstructionMemory_out_F)     
    );
	
	//BP STAGE
	logic BP_en_F;
	logic BP_en_DE;
	logic BP_en_EX;


	logic [31:0]BP_imm;

	Fetch_Decoder BP_Decoder(
		.inst(InstructionMemory_out_F),
		.branch_en(BP_en_F),
		.imm_out(BP_imm)

	);	

	logic BP_decision_F;
	logic BP_decision_DE;
	logic BP_decision_EX;
	
	Gshare_BP Gshare_BP(
		.clk(clk),
		.rst(rst),

		.branch_en_F(BP_en_F),
		.PC_F(PC_out_F[13:0]),
		.PC_EX(PC_out_EX[13:0]),

		.branch_result(alu_branch_control_EX),
		.branch_en_EX(BP_en_EX),
		.BP_decision(BP_decision_F)

	);
	
	
	/*
	LocalBP LocalBP(
		.clk(clk),
		.rst(rst),

		.branch_en_F(BP_en_F),
		.PC_F(PC_out_F),
		.PC_EX(PC_out_EX),

		.branch_result(alu_branch_control_EX),
		.branch_en_EX(BP_en_EX),
		.BP_decision(BP_decision_F)

	);
	*/

	/*
	BimodalBP BimodalBP(
		.clk(clk),
		.rst(rst),

		.branch_en_F(BP_en_F),
		.PC_F(PC_out_F[11:0]),
		.PC_EX(PC_out_EX[11:0]),

		.branch_result(alu_branch_control_EX),
		.branch_en_EX(BP_en_EX),
		.BP_decision(BP_decision_F)

	);
	*/
	logic [31:0]wire_x;

	Kogge_Stone Branch_Calculation(
		.in0(PC_out_F),
		.in1(BP_imm),
		
		.sub_en(1'b0),
		.out(wire_x)
	);

//////////////////////////////////////////////////		
	Decode_Register Decode_Reg_(
        .clk                    (clk),
        .rst                    (rst),
        .normal_F               (normal_F),
        .PC_out_F               (PC_out_F),
        .InstructionMemory_out_F(InstructionMemory_out_F),
		.BP_decision_F			(BP_decision_F),
		.BP_en_F				(BP_en_F),

        .stall_DE               (stall_DE),
		.flush_DE				(flush_DE),

		.BP_en_DE				(BP_en_DE),
		.BP_decision_DE			(BP_decision_DE),
        .normal_DE              (normal_DE),
        .PC_out_DE              (PC_out_DE),
        .InstructionMemory_out_DE(InstructionMemory_out_DE)
    );
//////////////////////////////////////////////////
	
	
	logic [4:0]op_code;
	logic [3:0]sub_op_code;
	
	logic [WIDTH-1:0]imm_decoded;
	
	//logic [4:0]shift_size;
	logic [4:0]shift_size_DE;
	logic [4:0]shift_size_EX;
	
	logic [4:0]rs1_DE;
	logic [4:0]rs1_EX;
	
	logic [4:0]rs2_DE;
	logic [4:0]rs2_EX;
	
	//logic [4:0]rd;
	logic [4:0]rd_DE;
	logic [4:0]rd_EX;
	logic [4:0]rd_MEM;
	logic [4:0]rd_WB;

	Decoder Decoder_(
        .inst(InstructionMemory_out_DE),
        
        .op_code(op_code),
        .sub_op_code(sub_op_code),
        
        .rs1(rs1_DE), 
        .rs2(rs2_DE),
        .rd(rd_DE),
        
        .imm(imm_decoded),
        .shift_size(shift_size_DE)
    );
	
	logic imm_en;
	
	//logic rf_write_en;
	logic rf_write_en_DE;
	logic rf_write_en_EX;
	logic rf_write_en_MEM;
	logic rf_write_en_WB;
	
	//logic mem_read_en;
	logic mem_read_en_DE;
	logic mem_read_en_MEM;
	
	//logic mem_write_en;
	logic mem_write_en_DE;
	logic mem_write_en_EX;
	logic mem_write_en_MEM;
	
	logic sign_extender_en_DE;
	logic sign_extender_en_EX;
	
	logic sign_extender_type;
	
	//logic [3:0]alu_op;
	logic [3:0]alu_op_DE;
	logic [3:0]alu_op_EX;
	
	//logic JAL_en;
	logic JAL_en_DE;
	logic JAL_en_EX;
	
	//logic JALR_en;
	logic JALR_en_DE;
	logic JALR_en_EX;
	
	
	//load_type
	logic [2:0]load_type_DE;
	logic [2:0]load_type_EX;
	logic [2:0]load_type_MEM;
	
	logic [1:0]store_type;
	
	Control_Unit Control_Unit_(
        .op_code(op_code),
        .sub_op_code(sub_op_code),
		
		.load_type(load_type_DE),
		.store_type(store_type),
		
		.JAL_en(JAL_en_DE),
		.JALR_en(JALR_en_DE),
        .imm_en(imm_en),
        .rf_write_en(rf_write_en_DE),
        .mem_read_en(mem_read_en_DE),
        .mem_write_en(mem_write_en_DE),
        .branch_mode(program_counter_controller_DE),
        .sign_extender_en(sign_extender_en_DE),
        .sign_extender_type(sign_extender_type),
        .alu_op(alu_op_DE)
    );
	
	logic [WIDTH-1:0]rd1;
	logic [WIDTH-1:0]rd1_DE;
	logic [WIDTH-1:0]rd1_EX;
	
	logic [WIDTH-1:0]rd2;
	logic [WIDTH-1:0]rd2_DE;
	logic [WIDTH-1:0]rd2_EX;
	logic [WIDTH-1:0]rd2_MEM;
	
	//logic [WIDTH-1:0]wd;
	logic [WIDTH-1:0]wd_MEM;
	logic [WIDTH-1:0]wd_WB;
	
	
	RF RF_(
        .rs1(rs1_DE),
        .rs2(rs2_DE),
        .rd(rd_WB),
        .wd(wd_WB),
		
        .clk(clk),
        .rst(rst),
		
        .write_en(rf_write_en_WB),
        .rd1(rd1),
        .rd2(rd2)
    );

	//logic [WIDTH-1:0]imm_sign_extender_out;
	logic [WIDTH-1:0]imm_sign_extender_out_DE;
	logic [WIDTH-1:0]imm_sign_extender_out_EX;

	Sign_Extender Sign_Extender_(
        .in(imm_decoded),
        .op_code(op_code),
		
        .sign_extender_en(sign_extender_en_DE),
        .sign_extender_type(sign_extender_type),
		
        .imm_out(imm_sign_extender_out_DE)
    );
	
	//logic [WIDTH-1:0]alu_in1; 
	logic [WIDTH-1:0]alu_in1_DE; 
	logic [WIDTH-1:0]alu_in1_EX; 
	assign rd1_DE = (JAL_en_DE) ? (PC_out_DE) : (rd1); 
	
	//logic [WIDTH-1:0]alu_in2;
		
	assign  rd2_DE = 	(store_type == 2'b00) ? rd2 					:						
						(store_type == 2'b01) ? {{24{1'b0}}, rd2[7:0]}  : 
						(store_type == 2'b10) ? {{16{1'b0}}, rd2[15:0]} :
						(store_type == 2'b11) ? rd2 : 32'd0;	

	/////////////////////////////////////////////////
	Execute_Register Execute_Register_(
        .clk(clk),
        .rst(rst),
		
        .normal_DE(normal_DE),
        .PC_out_DE(PC_out_DE),
        .program_counter_controller_DE(program_counter_controller_DE),
        .JALR_en_DE(JALR_en_DE),
        .JAL_en_DE(JAL_en_DE),
		
		.shift_size_DE(shift_size_DE),
		.alu_op_DE(alu_op_DE),
        
		.rd_DE(rd_DE),
        .rf_write_en_DE(rf_write_en_DE),
        .mem_read_en_DE(mem_read_en_DE),
        .mem_write_en_DE(mem_write_en_DE),
        

        .imm_sign_extender_out_DE(imm_sign_extender_out_DE),
		.rd1_DE(rd1_DE),
		.rd2_DE(rd2_DE),
		.rs1_DE(rs1_DE),
		.rs2_DE(rs2_DE),
		
		.sign_extender_en_DE(sign_extender_en_DE),
		
		
		.flush_EX(flush_EX),
		.load_type_DE(load_type_DE),
		.load_type_EX(load_type_EX),

		.BP_decision_DE(BP_decision_DE),
		.BP_en_DE(BP_en_DE),
		//-----------------------------------------------
		
        .normal_EX(normal_EX),
        .PC_out_EX(PC_out_EX),
        .program_counter_controller_EX(program_counter_controller_EX),
        .JALR_en_EX(JALR_en_EX),
        .JAL_en_EX(JAL_en_EX),
		
		.shift_size_EX(shift_size_EX),
        .rd_EX(rd_EX),
        .rf_write_en_EX(rf_write_en_EX),
        .mem_read_en_EX(mem_read_en_EX),
        .mem_write_en_EX(mem_write_en_EX),
        .alu_op_EX(alu_op_EX),
		
		.sign_extender_en_EX(sign_extender_en_EX),
        .imm_sign_extender_out_EX(imm_sign_extender_out_EX),
		.rd1_EX(rd1_EX),
		.rd2_EX(rd2_EX),
		.rs1_EX(rs1_EX),
		.rs2_EX(rs2_EX),

		.BP_decision_EX(BP_decision_EX),
		.BP_en_EX(BP_en_EX)
    );
	/////////////////////////////////////////////////
	
	//logic [WIDTH-1:0]alu_out;
	logic [WIDTH-1:0]alu_in2_EX;
	//logic [WIDTH-1:0]alu_in2_MEM;
	
	logic [WIDTH-1:0]alu_out_EX;
	logic [WIDTH-1:0]alu_out_MEM;
	
	logic [31:0]alu_in1;
	logic [WIDTH-1:0]alu_in2;
	
	logic [WIDTH-1:0]rd2_EX2;

	assign 	alu_in1 = 	(forward_mode_rs1 == 2'b00) ? (rd1_EX) 	: 
						(forward_mode_rs1 == 2'b01) ? (alu_out_MEM) 	:
						(forward_mode_rs1 == 2'b11) ? (wd_WB) : rd1_EX	;
	
	assign 	rd2_EX2 = 	(forward_mode_rs2 == 2'b00) ? (rd2_EX) 	: 
						(forward_mode_rs2 == 2'b01) ? (alu_out_MEM) 	:
						(forward_mode_rs2 == 2'b11) ? (wd_WB) : rd2_EX	;
	
	assign alu_in2_EX =	(program_counter_controller_EX == 2'b11) ? (rd2_EX2): 
						(sign_extender_en_EX) ? (imm_sign_extender_out_EX) 	: (rd2_EX2);
				 
	ALU ALU_(
        .rs1(alu_in1),
        .rs2(alu_in2_EX),
		.shifter_size(shift_size_EX),
        .op(alu_op_EX),
		
        .result(alu_out_EX),
        .branch_control(alu_branch_control_EX)
    );
	
	logic branch_en_EX;
	assign branch_en_EX = (alu_op_EX == 4'b1010) || (alu_op_EX == 4'b1001)	|| 	(alu_op_EX == 4'b1011) || (alu_op_EX == 4'b1100);

	assign jump_EX = (JAL_en_EX) ? (alu_out_EX) : (JALR_en_EX ? {alu_out_EX[31:1] , 1'b0} : 32'd0);
	/*
	Kogge_Stone Branch_Calculation(
		.in0(normal_EX),
		.in1(imm_sign_extender_out_EX),
		
		.sub_en(1'b0),
		.out(branch_EX)
	);
	*/

	//////////////////////////////////////
	Memory_Register Memory_Register_(
        .clk(clk),
        .rst(rst),
        .jump_EX(jump_EX),
        .branch_EX(branch_EX),
        .normal_EX(normal_EX),
        .PC_out_EX(PC_out_EX),
        .program_counter_controller_EX(program_counter_controller_EX),
        .alu_branch_control_EX(alu_op_EX),
        .rd_EX(rd_EX),
        .rf_write_en_EX(rf_write_en_EX),
        .mem_read_en_EX(mem_read_en_EX),
        .mem_write_en_EX(mem_write_en_EX),
        .rd2_EX(rd2_EX2),
		.alu_out_EX(alu_out_EX),
		
		.load_type_EX(load_type_EX),
		.load_type_MEM(load_type_MEM),
		
		.alu_out_MEM(alu_out_MEM),
        .jump_MEM(jump_MEM),
        .branch_MEM(branch_MEM),
        .normal_MEM(normal_MEM),
        .PC_out_MEM(PC_out_MEM),
        .program_counter_controller_MEM(program_counter_controller_MEM),
        .alu_branch_control_MEM(alu_branch_control_MEM),
        .rd_MEM(rd_MEM),
        .rf_write_en_MEM(rf_write_en_MEM),
        .mem_read_en_MEM(mem_read_en_MEM),
        .mem_write_en_MEM(mem_write_en_MEM),
        .rd2_MEM(rd2_MEM)
    );
	//////////////////////////////////////
	
	//logic [WIDTH-1:0]memory_out;
	logic [WIDTH-1:0]memory_out_MEM;
	logic [WIDTH-1:0]memory_out;
	
	Memory Memory_(
    .mem_read_en(mem_read_en_MEM),
    .mem_write_en(mem_write_en_MEM),
    .clk(clk),
    .rst(rst),
    .address(alu_out_MEM),
    .write_data(rd2_MEM),
    .read_data(memory_out)
	);
	
	assign memory_out_MEM = 
    (load_type_MEM == 3'b001) ? {{24{memory_out[7]}}  , memory_out[7:0]}  :
    (load_type_MEM == 3'b010) ? {24'd0              , memory_out[7:0]}  :
    (load_type_MEM == 3'b011) ? {{16{memory_out[15]}} , memory_out[15:0]} :
    (load_type_MEM == 3'b100) ? {16'd0              , memory_out[15:0]} :
    (load_type_MEM == 3'b101) ? {memory_out[31:0]}  :
    32'd0;

	
							
	
	assign wd_MEM = (mem_read_en_MEM) ? (memory_out_MEM) : ((program_counter_controller_MEM == 2'b10) ? normal_MEM : alu_out_MEM);
	
	WriteBack_Register WriteBack_Register_ (
        .clk(clk),
        .rst(rst),
        .alu_branch_control_MEM(alu_branch_control_MEM),
        .mem_write_en_MEM(mem_write_en_MEM),
        .mem_read_en_MEM(mem_read_en_MEM),
        .rd2_MEM(rd2_MEM),
        .program_counter_controller_MEM(program_counter_controller_MEM),
        .rd_MEM(rd_MEM),
        .rf_write_en_MEM(rf_write_en_MEM),
        .wd_MEM(wd_MEM),
        .PC_out_MEM(PC_out_MEM),
        .normal_MEM(normal_MEM),
        .program_counter_controller_WB(program_counter_controller_WB),
        .rd_WB(rd_WB),
        .rf_write_en_WB(rf_write_en_WB),
        .wd_WB(wd_WB),
        .PC_out_WB(PC_out_WB),
        .normal_WB(normal_WB)
    );
	
	Hazard_Unit Hazard_Unit_(
        .rs1_DE          (rs1_DE),
        .rs1_EX          (rs1_EX),
        .rs2_DE          (rs2_DE),
        .rs2_EX          (rs2_EX),
        .rd_EX           (rd_EX),
        .rd_MEM          (rd_MEM),
        .rd_WB           (rd_WB),
        .mem_read_en_EX  (mem_read_en_EX),
        .rf_write_en_MEM (rf_write_en_MEM),
        .rf_write_en_WB  (rf_write_en_WB),
		
		.branch_control(alu_branch_control_EX),
		.branch_decision(BP_decision_EX),
		.branch_correction(branch_correction),

		.program_counter_controller_EX(program_counter_controller_EX),

        .forward_mode_rs1    (forward_mode_rs1),
		.forward_mode_rs2	 (forward_mode_rs2),
        .stall_DE        (stall_DE),
        .stall_F         (stall_F),
        .flush_EX        (flush_EX),
		.flush_DE        (flush_DE)
    );
	
	

endmodule

module MUX_PC #(
	parameter WIDTH = 32
	)(
	input logic [WIDTH-1:0]jump, 
	input logic [WIDTH-1:0]branch, 
	input logic [WIDTH-1:0]normal_F,
	input logic [WIDTH-1:0]normal_EX,
	
	input logic branch_correction,

	input logic branch_en,
	input logic branch_en_F,
	input logic branch_en_EX,

	input logic [1:0]program_counter_controller,
	
	output logic [WIDTH-1:0]out	
);	
	always_comb
	begin
		if(branch_en_EX)
		begin
			if(branch_correction)
			begin
				out = normal_EX;
			end
			else
			begin
				out = branch;
			end
			
		end

		else if(branch_en_F)
		begin
				out = branch;
		end

		else
		begin
			case({program_counter_controller , branch_en})
				3'b010: 	begin  out = normal_F; 	end //normal
				3'b100: 	begin  out = jump; 		end //jump
				default: 	begin  out = normal_F ; 	end //begin  out = 32'd4; 	end
			endcase
		end
	end
endmodule
