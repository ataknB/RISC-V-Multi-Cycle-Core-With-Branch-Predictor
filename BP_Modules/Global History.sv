module GlobalHistoryBP(
    input logic clk,
    inpuy logic rst,

    input logic branch_result,
    input logic branch_en,
    output logic 
);
    logic [13:0]GHR;
    logic [13:0]GHR_reg;

    logic [13:0]GHT[4095:0];

    always_ff @(posedge clk, negedge rst)
    begin
        if(!rst)
        begin
            GHR <= 14'd0;
            GHR_reg <= 14'd0;
        end
        else if(branch_en)
        begin
            GHR <= {GHR_reg[13:1] ,  branch_result};
            GHR_reg <= GHR;
        end
    end    

    

endmodule