module BimodalBP(
    input logic clk,
    input logic rst,

    input logic branch_en,
    input logic branch_result,      //real branch result
    input logic [13:0]PC,

    output logic BP_decision    //predicted result
);
    logic [1:0]BHT[4095:0];
    integer i;    


    always_ff @(posedge clk, negedge rst)
    begin
        if(!rst)
        begin
            for(i = 0 ; i < 4096 ; i = i+1)
                BHT[i] <= 2'd10;
        end
        else
        begin
            if(branch_result)
            begin
                case(BHT[PC])
                    2'b11:      begin BHT[PC] <= 2'b11; end
                    2'b10:      begin BHT[PC] <= 2'b11; end
                    2'b01:      begin BHT[PC] <= 2'b10; end
                    2'b00:      begin BHT[PC] <= 2'b01; end
                    default:    begin BHT[PC] <= 2'b01; end
                endcase
            end
            else
            begin
                case(BHT[PC])
                    2'b11:      begin BHT[PC] <= 2'b10; end
                    2'b10:      begin BHT[PC] <= 2'b01; end
                    2'b01:      begin BHT[PC] <= 2'b00; end
                    2'b00:      begin BHT[PC] <= 2'b00; end
                    default:    begin BHT[PC] <= 2'b01; end
                endcase
            end
        end    
    end

    

    assign BP_decision = (branch_en) ? (BHT[PC][1]) : 1'b0; 


endmodule