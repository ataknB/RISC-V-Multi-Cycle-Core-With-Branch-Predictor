module Gshare_BP(
    input logic clk,
    input logic rst,

    input logic [13:0]PC_F,
    input logic [13:0]PC_EX,

    input logic branch_en_EX,
    input logic branch_en_F,

    input logic branch_result,
    output logic BP_decision
    );

    integer i = 0;
    logic [13:0]GHT[4095];
    logic [1:0]PHT[4095];

    logic [13:0]GHT_to_PHT_F;
    logic [13:0]GHT_to_PHT_EX;

    logic [13:0]shifter_out;
    logic [13:0]shifter_in;


    assign shifter_in = shifter_out; 

    always_ff @(posedge clk, negedge rst)
    begin

        if(!rst)
        begin
            for(i = 0; i < 4096 ; i = i+1)
            begin
                GHT[i] <= 14'd0;
                PHT[i] <= 2'b10;
            end
            shifter_out <= 14'd0;
            GHT_to_PHT_EX <= 14'd0;
            GHT_to_PHT_F <= 14'd0;
        end

        else
        begin
            if(branch_en_F)
            begin
                GHT_to_PHT_F <= PC_F ^ GHT[PC_F];
            end

            else if(branch_en_EX)
            begin
                shifter_out <= {shifter_out[13:0] , branch_result};
                
                GHT_to_PHT_EX <= shifter_in ^ PC_EX;

                if(branch_result)
                begin
                    case(PHT[GHT_to_PHT_EX])
                        2'b11: begin PHT[GHT_to_PHT_EX] <= 2'b11; end
                        2'b10: begin PHT[GHT_to_PHT_EX] <= 2'b11; end
                        2'b01: begin PHT[GHT_to_PHT_EX] <= 2'b10; end
                        2'b00: begin PHT[GHT_to_PHT_EX] <= 2'b01; end
                        default: begin PHT[GHT_to_PHT_EX] <= 2'b10; end
                    endcase
                end

                else
                begin
                    case(PHT[GHT_to_PHT_EX])
                        2'b11: begin PHT[GHT_to_PHT_EX] <= 2'b10; end
                        2'b10: begin PHT[GHT_to_PHT_EX] <= 2'b01; end
                        2'b01: begin PHT[GHT_to_PHT_EX] <= 2'b00; end
                        2'b00: begin PHT[GHT_to_PHT_EX] <= 2'b00; end
                        default: begin PHT[GHT_to_PHT_EX] <= 2'b10; end
                    endcase
                end
            end

            else
            begin
                
            end
        end
    end

    assign BP_decision = (branch_en_F) ? PHT[GHT_to_PHT_F][1] : 1'b0;


endmodule