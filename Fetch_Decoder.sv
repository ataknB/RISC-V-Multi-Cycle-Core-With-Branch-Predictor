module Fetch_Decoder(
	input logic  [31:0]inst,
	
    output logic branch_en,
    output logic [31:0]imm_out
	
	);

    logic [31:0]imm;
    logic [4:0]sub_op_code;
    logic sign_extender_type;

	always_comb
	begin
            if(inst[6:2] == 5'b11000)
            begin
                branch_en       = 1'b1;
                sub_op_code 	= 	{1'b0 , inst[14:12]};
                imm             = {inst[31]/*12*/, inst[7]/*11*/, inst[30:25]/*10:5*/, inst[11:8]/*4:1*/, 1'b0};

               // imm				=	{19'd0 , inst[31] , inst[7] , inst[30] , inst[29]  , inst[28]  , inst[27]  , inst[26]  , inst[25]  , inst[11] ,   inst[10] , inst[9]  , inst[8] , 1'b0};
                
                casex(sub_op_code)
                    4'bx000:// beq
                    begin
                        sign_extender_type	=	1'b0;
                    end	
                    
                    
                    4'bx001:// bne
                    begin
                        sign_extender_type	=	1'b0;
                    end	
                    
                    
                    4'bx100:// blt
                    begin
                        sign_extender_type	=	1'b0;
                    end	
                    
                    4'bx101:// bge
                    begin
                        sign_extender_type	=	1'b1;
                    end	
                
                    4'bx110:// bltu
                    begin
                        sign_extender_type	=	1'b1;
                    end	
                    
                    4'bx111:// bgeu
                    begin
                        sign_extender_type	=	1'b1;
                    end	
                    
                    default:
                    begin
                        sign_extender_type	=	1'b0;
                    end
                endcase
            end
            
            else
            begin
                branch_en = 1'b0;
            end
	end   

    Sign_Extender Sign_Extender(
        .in(imm),
        
        .op_code(5'b11000),
        .sign_extender_en(1'b1),
        .sign_extender_type(sign_extender_type),

        .imm_out(imm_out)
    );


endmodule
