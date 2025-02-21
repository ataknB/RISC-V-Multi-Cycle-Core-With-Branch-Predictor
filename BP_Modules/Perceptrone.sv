module Perceptrone_BP#(
    
) (
    input logic clk,
    input logic rst,

    input logic [31:0]PC_F,
    input logic [31:0]PC_EX,

    input logic branch_en_EX,
    input logic branch_en_F,

    input logic branch_correction,
    input logic branch_result,
    
    output logic BP_decision
);
    
    logic [13:0]GHR;
    logic [13:0]Precisition_Reg;
    logic [13:0]Hashed_Address;
    logic [14:0]Perceptrone_Table[4095];

    

    logic [14:0]Perceptrone_Out[14:0];
    logic [14:0]Cal_in[14:0];

    integer i = 0;

    //Table ve Reg ayarlama

    always_ff @(posedge clk, negedge rst)
    begin

        if(!rst)
        begin
            for(i = 0; i < 4096 ; i = i+1)
            begin
                Perceptrone_Table[i] <= 15'd0;
            end

            GHR <= 14'd0;
        end

        else
        begin
            if(branch_en_EX)
            begin
                GHR <= {GHR[12:0], branch_result};
                Hashed_Address <= (PC_EX ^ GHR);
            end

            else 
            begin
                GHR <= GHR;
            end    

            if(branch_correction)
            begin
                
            end

        end
    end

        //Hesaplama
        assign Cal_in[0] = Perceptrone_Out[0];


        logic [14:0]adder_out[12:0];

        Kogge_Stone Cal_(
                    .in0(Cal_in[0]),
                    .in1(Cal_in[1]),
                    .sub_en(1'b0),
                    .out(adder_out[0])
                );
    
        generate
            for(i = 0 ; i< 15 ; i = i+1)
            begin
                assign Cal_in[i+1] = GHR[i] ? (Perceptrone_Out[i+1]) : (14'd0);
            end


            for(i = 2 ; i < 15 ; i = i+1)
            begin
                Kogge_Stone Cal_(
                    .in0(Cal_in[i]),
                    .in1(adder_out[i-2]),
                    .sub_en(1'b0),
                    .out(adder_out[i-1])
                );
            end
        endgenerate
    

    //Training




endmodule