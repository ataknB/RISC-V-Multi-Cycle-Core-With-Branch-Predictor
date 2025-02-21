module LocalBP(
    input logic clk,
    input logic rst,

    input logic [31:0] PC_F,
    input logic [31:0] PC_EX,

    input logic branch_en_EX,
    input logic branch_en_F,

    output logic branch_result,
    output logic BP_decision
    );

    integer i = 0;
    logic [13:0] BHT [0:4095]; // 14-bit genişliğinde 4096 girişli BHT
    logic [1:0] PHT [0:4095];  // 2-bit genişliğinde 4096 girişli PHT

    logic [13:0] wire_BHT_to_PHT;
    logic [13:0] shifter_out;

    always_ff @(posedge clk or negedge rst) begin
        if (!rst) begin
            // Reset durumunda BHT ve PHT sıfırlanır
            for (i = 0; i < 4096; i = i + 1) begin
                BHT[i] <= 14'd0;
                PHT[i] <= 2'b10;
            end
            shifter_out <= 14'd0;
        end 
        else begin
            // Shifter güncelleme
            if (branch_en_EX) begin
                shifter_out <= {shifter_out[12:0], branch_result};
            end

            // Branch History Table güncelleme
            if (branch_en_F) begin
                wire_BHT_to_PHT <= BHT[PC_F[13:2]]; // PC adresinin sadece belirli kısmını alıyoruz
            end

            else if (branch_en_EX) begin
                BHT[PC_EX[13:2]] <= shifter_out;

                if (branch_result) begin
                    case (PHT[PC_EX[13:2]])
                        2'b11: PHT[PC_EX[13:0]] <= 2'b11;
                        2'b10: PHT[PC_EX[13:0]] <= 2'b11;
                        2'b01: PHT[PC_EX[13:0]] <= 2'b10;
                        2'b00: PHT[PC_EX[13:0]] <= 2'b01;
                        default: PHT[PC_EX[13:0]] <= 2'b10;
                    endcase
                end 
                else begin
                    case (PHT[PC_EX[13:0]])
                        2'b11: PHT[PC_EX[13:0]] <= 2'b10;
                        2'b10: PHT[PC_EX[13:0]] <= 2'b01;
                        2'b01: PHT[PC_EX[13:0]] <= 2'b00;
                        2'b00: PHT[PC_EX[13:0]] <= 2'b00;
                        default: PHT[PC_EX[13:0]] <= 2'b10;
                    endcase
                end
            end

            else
            begin

            end
        end
    end

    assign BP_decision = (branch_en_F) ? PHT[PC_F[13:2]][1] : 1'b0;

endmodule
/*
0x00000513
0x00a00593
0x00500293
0x00000313
0x00550463
0x00c0006f
0x00100393
0x0080006f
0x00200393
0x00150513
0xfeb514e3
0x00000613
0x00a00693
0x00160613
0xfed61ee3
0x0040006f
0x02a00713
0x008000ef
0x00c0006f
0x00170713
0x00008067
0x00a00893
0x00000073
*/