`timescale 1ns/1ps

module BimodalBP_tb;
    reg clk;
    reg rst;
    reg branch_en;
    reg branch_result;
    reg [13:0] PC;
    wire BP_decision;
    reg [1:0] expected_BP_state;
    
    // Instantiate the module
    BimodalBP uut (
        .clk(clk),
        .rst(rst),
        .branch_en(branch_en),
        .branch_result(branch_result),
        .PC(PC),
        .BP_decision(BP_decision)
    );
    
    // Clock generation
    always #5 clk = ~clk; // 10 ns period (100 MHz clock)
    
    initial begin
        // Initialize signals
        clk = 0;
        rst = 0;
        branch_en = 0;
        branch_result = 0;
        PC = 0;
        expected_BP_state = 2'b00;
        
        // Reset phase
        #10 rst = 1;
        #10 rst = 0;
        #10 rst = 1;
        
        // Test case 1: First branch taken (should increment counter)
        PC = 14'h00A;
        branch_en = 1;
        branch_result = 1;
        expected_BP_state = 2'b01;
        #10;
        
        // Test case 2: Branch not taken (should decrement counter)
        branch_result = 0;
        expected_BP_state = 2'b00;
        #10;
        
        // Test case 3: Branch taken multiple times
        branch_result = 1;
        expected_BP_state = 2'b01;
        #10;
        branch_result = 1;
        expected_BP_state = 2'b10;
        #10;
        branch_result = 1;
        expected_BP_state = 2'b11;
        #10;
        
        // Test case 4: Branch not taken multiple times
        branch_result = 0;
        expected_BP_state = 2'b10;
        #10;
        branch_result = 0;
        expected_BP_state = 2'b01;
        #10;
        branch_result = 0;
        expected_BP_state = 2'b00;
        #10;
        
        // Test case 5: Change PC and test again
        PC = 14'h01F;
        branch_result = 1;
        expected_BP_state = 2'b01;
        #10;
        branch_result = 0;
        expected_BP_state = 2'b00;
        #10;
        
        // End simulation
        #50;
        $finish;
    end
    
    // Monitor changes
    initial begin
        $monitor("Time=%0t | PC=%h | branch_en=%b | branch_result=%b | BP_decision=%b | Expected_BP_state=%b", 
                 $time, PC, branch_en, branch_result, BP_decision, expected_BP_state);
    end
    
endmodule