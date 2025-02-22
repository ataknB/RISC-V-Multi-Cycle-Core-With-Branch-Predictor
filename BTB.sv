module  BTB#(
    
) ( 
    input logic clk,
    input logic rst,
    input logic [31:0]PC_F,
    input logic [31:0]PC_EX,
    input logic [31:0]Branch_Destinaiton,

    input logic write_en,
    input logic read_en,


    output logic [31:0]Branch_Decision,
);
    
    logic [31:0]BTB_Table[255:0];
    logic [31:0]BTB_Table_reg[255:0];

    always_ff @(posedge clk, negedge rst)
    begin
        if(!rst)
        begin
            for(i = 0 ; i < 256 ; i = i+1)
            begin
                BTB_Table[i] <= 32'd0;
                BTB_Table_reg[i] <= 32'd0;
            end
        end

        else
        begin
            if(write_en)
            begin
                BTB_Table[PC_EX] <= Branch_Destinaiton;
            end
            else
            begin
                BTB_Table_reg[PC_EX] <= BTB_Table[PC_EX];
            end
        end        
    end

    assign Branch_Decision = (read_en) ? BTB_Table[PC_F] : 32'd0;

endmodule