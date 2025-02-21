module Perceptrone_BP#(
    parameter H = 10,           // GHR uzunluğu
    parameter N = 1024,         // Tablo satır sayısı
    parameter W_WIDTH = 8       // Ağırlık genişliği 
) (
    input logic clk,
    input logic rst,

    input logic [9:0]PC_F,
    input logic [9:0]PC_EX,

    input logic branch_en_EX,
    input logic branch_en_F,

    input logic branch_correction,
    input logic branch_result,
    
    output logic BP_decision
);
    
    logic [7:0]Perceptrone_Table[1023:0][9:0];
    logic [9:0]GHR;

    logic [9:0]Hashed_Address_F;
    logic [9:0]Hashed_Address_EX;

    logic [7:0]Table_out[9:0];

    integer i;
    integer j;

    assign Hashed_Address_F = PC_F ^ GHR;

    always_ff @(posedge clk, negedge rst)
    begin
        if(!rst)
        begin
            for(i = 0 ; i < 1024 ; i = i+1)
            begin
                for(j = 0; j < 10 ; j = j+1)
                begin
                    Perceptrone_Table[i][j] <= 8'd0;
                end
            end

            GHR <= 10'd0;
        end

        else
        begin

        end
    end

    assign Table_out = Perceptrone_Table[Hashed_Address_F];

    

endmodule