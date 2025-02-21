module Perceptrone_BP#(
    parameter H = 12,           // GHR uzunluğu
    parameter N = 4096,         // Tablo satır sayısı
    parameter W_WIDTH = 13       // Ağırlık genişliği 
) (
    input logic clk,
    input logic rst,

    input logic [11:0]PC_F,
    input logic [11:0]PC_EX,

    input logic branch_en_EX,
    input logic branch_en_F,

    input logic branch_correction,
    input logic branch_result,
    
    output logic BP_decision
);
    
    logic [11:0]GHR;
    logic [11:0]Precisition_Reg;
    logic [11:0]Hashed_Address;
    logic [W_WIDTH-1:0] Perceptrone_Table [N-1:0] [H:0];

    logic [12:0]training_result[12:0];

    logic [12:0]Perceptrone_Out[12:0];
    logic [12:0]Cal_in[12:0];

    integer i = 0;
    integer j = 0;
    genvar x;
    

    logic [W_WIDTH-1:0]result_vector; 

    generate
        for (x = 0; x < 13 ; x = x+1 ) 
        begin
            assign result_vector[x] = branch_result; 
        end
    endgenerate


    //Table ve Reg ayarlama

    always_ff @(posedge clk, negedge rst)
    begin

        if(!rst)
        begin
            for(i = 0; i < 4096 ; i = i+1)
            begin
                for(j = 0; j < 13 ; j = i+1)
                Perceptrone_Table[i][j] <= 8'd0;
            end

            GHR <= 14'd0;
        end

        else
        begin
            if(branch_en_EX)
            begin
                GHR <= {GHR[12:0], branch_result};
                Hashed_Address <= (PC_EX ^ GHR);

                    if(branch_correction)
                    begin

                        training_result[0] = Perceptrone_Table[PC_EX ^ GHR][0]  + branch_result;

                        for( x = 1; x < 13 ; x = x+1)
                        begin
                            training_result[x] = Perceptrone_Table[PC_EX ^ GHR][x]  + (result_vector && GHR[x-1]);
                        end
                    end
            end

            else 
            begin
                GHR <= GHR;
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
            for(x = 0 ; x< 15 ; x = x+1)
            begin
                assign Cal_in[x+1] = GHR[x] ? (Perceptrone_Out[x+1]) : (14'd0);
            end


            for(x = 2 ; x < 15 ; x = x+1)
            begin
                Kogge_Stone Cal_(
                    .in0(Cal_in[x]),
                    .in1(adder_out[x-2]),
                    .sub_en(1'b0),
                    .out(adder_out[x-1])
                );
            end
        endgenerate
    
endmodule